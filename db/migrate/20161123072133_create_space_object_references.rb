class CreateSpaceObjectReferences < ActiveRecord::Migration[5.0]
  def change
    create_table :space_object_references, id: :uuid do |t|
      t.uuid :from_id, null: false
      t.string :to_address, null: false
    end
  end
end
