class Import < ApplicationRecord
  has_many :heap_dumps
  has_many :space_objects, through: :heap_dumps
  mount_uploaders :graphs, GraphUploader

  scope :recent, -> { order(created_at: :desc).limit(10) }
end
