class SpaceObjectReference < ApplicationRecord
  belongs_to :from, class_name: 'SpaceObject', required: true, inverse_of: 'references'
  belongs_to :to, class_name: 'SpaceObject', foreign_key: 'to_address', primary_key: 'address'
end
