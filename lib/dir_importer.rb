require 'ruby-progressbar'
require 'json'
require 'csv'

class DirImporter
  FIELDS = %w(
    id heap_dump_id type node_type root address value klass name struct file line method generation
    size length memsize bytesize capacity ivars fd encoding default_address freezed fstring
    embedded shared flag_wb_protected flag_old flag_long_lived flag_marking flag_marked
  ).freeze
  REF_FIELDS = %w(id from_id to_address).freeze

  attr_reader :dir, :import

  def initialize(directory)
    @import = Import.new
    @dir = directory
  end

  def run
    Dir["#{dir}/*"].each do |file|
      next unless File.file?(file)

      filename = File.basename(file)
      timestamp = filename.match(/\b(1[0-9]{9})\b/)[0].to_i
      raise('Filename must include uniq timestamp e.g. heap-1479820044.dump') if timestamp.zero?
      import_file(import, file, Time.at(timestamp))
    end
    db_vacuum
    self
  end

  private

  def import_file(import, file, time) # rubocop:disable Metrics/MethodLength
    import.save
    dump = import.heap_dumps.create(time: time)
    progressbar = ProgressBar.create(title: file, format: '%t |%B| %c/%C %E', throttle_rate: 0.5)
    import_values(SpaceObjectReference, REF_FIELDS) do |ref_csv|
      import_values(SpaceObject, FIELDS) do |csv|
        parse_dump(file) do |data, count|
          progressbar.total = count

          id = SecureRandom.uuid
          refs = data.delete('references') || []

          data['id'] = id
          data['heap_dump_id'] = dump.id
          data['value'] = data['value'].gsub(/[^[:print:]]/, '.') if data['value']
          data['klass'] = data.delete('class') if data['class']
          data['freezed'] = data.delete('frozen') if data['frozen']
          data['default_address'] = data.delete('default') if data['default']
          (data.delete('flags') || {}).each { |k, v| data["flag_#{k}"] = v }
          data['default_address'] = data.delete('default') if data['default']

          csv << FIELDS.map { |f| data[f] }
          refs.each do |ref|
            ref_csv << [SecureRandom.uuid, id, ref]
          end

          progressbar.increment
        end
      end
    end
    true
  end

  def db_vacuum
    ActiveRecord::Base.connection.execute('VACUUM ANALYZE')
  end

  def parse_dump(filename)
    lines = open(filename).readlines
    lines.each do |line|
      yield(JSON.parse(line), lines.count)
    end
  end

  def import_values(klass, fields)
    values = []
    yield(values)
    db_import(klass, fields, values)
  end

  def db_import(klass, fields, values) # rubocop:disable Metrics/MethodLength
    puts "Importing #{klass.name.pluralize}"
    conn = klass.connection_pool.checkout
    raw = conn.raw_connection
    cmd = "COPY #{klass.table_name} (#{fields.join(',')}) FROM STDIN"
    result = raw.copy_data(cmd, PG::TextEncoder::CopyRow.new) do
      values.each do |row_values|
        raw.put_copy_data row_values
      end
    end
    ActiveRecord::Base.connection_pool.checkin(conn)
    puts "Imported #{result.inspect}"
  end
end
