class CreateGraphService
  TYPES = %w(type-mem type-count string-count string-mem data-count data-mem).freeze

  attr_reader :import, :type

  def initialize(import, type:)
    @import = import
    @type = type.presence || 'type-mem'
  end

  def call
    @import.graphs += [create_graph]
    @import.save
  end

  private

  def create_graph # rubocop:disable Metrics/MethodLength
    case type
    when 'type-count'
      ylabel = 'count'
      query, ycolumn, group = nil, 'COUNT(space_objects.id)', :type
      key_pos = 'left top'
    when 'type-mem'
      query, ycolumn, group = nil, 'SUM(memsize)', :type
      ylabel, yscale = 'memsize [MB]', 1024*1024
      key_pos = 'left top'
    when 'string-count'
      ylabel = 'count'
      query, ycolumn, group = { type: 'STRING' }, 'COUNT(space_objects.id)', :file
    when 'string-mem'
      query, ycolumn, group = { type: 'STRING' }, 'SUM(space_objects.memsize)', :file
      ylabel, yscale = 'memsize [MB]', 1024*1024
    when 'data-count'
      ylabel = 'count'
      query, ycolumn, group = { type: 'DATA' }, 'COUNT(space_objects.id)', :file
    when 'data-mem'
      query, ycolumn, group = { type: 'DATA' }, 'SUM(space_objects.memsize)', :file
      ylabel, yscale = 'memsize [MB]', 1024*1024
    else
      raise('Unsupported grapth type')
    end

    scope = @import.space_objects.joins(:heap_dump)
    scope = scope.where(**query) if query
    scope = scope.order(ycolumn + ' DESC NULLS LAST')
    scope = scope.group(HeapDump.arel_table[:time], group)
    data = scope.limit(500).pluck(group, HeapDump.arel_table[:time], ycolumn)

    graph = ImageIO.new("#{@import.id}-#{type}.png")
    graph << Gnuplot.open(persist: false) do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal 'png large'

        plot.xdata :time
        plot.timefmt '"%s"'
        plot.format 'x "%H:%M"'

        plot.xlabel 'time'
        plot.ylabel ylabel
        plot.key key_pos if key_pos

        grouped_data = data.group_by(&:first)
        keys = grouped_data.keys.sort_by do |key|
          -grouped_data[key].reduce(0) { |sum, d| sum + (d[2]||0) }
        end
        keys[0, 10].each do |key|
          data = grouped_data[key]
          data.sort_by! { |d| d[1] }
          x = data.map { |d| d[1].to_i }
          y = data.map { |d| d[2] }
          y = data.map { |d| (d[2]||0) / (yscale||1) }
          plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
            ds.using = '1:2'
            ds.with = 'linespoints'
            ds.title = key || '(empty)'
          end
        end
      end
    end
  end
end
