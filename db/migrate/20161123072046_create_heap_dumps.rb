class CreateHeapDumps < ActiveRecord::Migration[5.0]
  def change
    create_table :heap_dumps, id: :uuid do |t|
      t.belongs_to :import, index: true, foreign_key: true, type: :uuid
      t.datetime :time
      t.timestamps
    end
  end
end
