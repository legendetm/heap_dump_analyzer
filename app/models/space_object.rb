class SpaceObject < ApplicationRecord
  self.inheritance_column = 'space_object_type'

  belongs_to :heap_dump
  has_many :references, class_name: 'SpaceObjectReference', foreign_key: 'from_id',
           inverse_of: 'from', dependent: :destroy
  has_one :default, class_name: 'SpaceObject', foreign_key: 'default', primary_key: 'address'

  scope :exists_in_heap_dump, ->(heap_dump) do
    q = SpaceObject.arel_table
    sq = q.alias
    all.where_exists(
      SpaceObject.unscoped.select(sq[:id]).from(sq).
        where(sq[:heap_dump_id].eq(heap_dump.to_param).and(sq[:address].eq(q[:address])))
    )
  end

  scope :exclude_heap_dump, ->(heap_dump) do
    q = SpaceObject.arel_table
    sq = q.alias
    all.where_not_exists(
      SpaceObject.unscoped.select(sq[:id]).from(sq).
        where(sq[:heap_dump_id].eq(heap_dump.to_param).and(sq[:address].eq(q[:address])))
    )
  end

  def self.diff(heap_dumps)
    heap_dumps = heap_dumps.to_a
    exclude = heap_dumps.shift
    heap_dumps.reduce(heap_dumps.shift.space_objects.exclude_heap_dump(exclude)) do |rel, union|
      rel.exists_in_heap_dump(union)
    end
  end

  def alloc_info(length = nil)
    "#{length ? file.last(length) : file}:#{line}" if file && line
  end
end
