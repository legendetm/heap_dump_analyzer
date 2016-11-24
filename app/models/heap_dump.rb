class HeapDump < ApplicationRecord
  has_many :space_objects

  scope :recent, -> { distinct(:import).order(created_at: :desc).limit(10) }
  scope :with_import, ->(query) { where(import: query) }
end
