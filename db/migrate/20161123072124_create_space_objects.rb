class CreateSpaceObjects < ActiveRecord::Migration[5.0]
  def change
    create_table :space_objects, id: :uuid do |t|
      t.belongs_to :heap_dump, index: true, foreign_key: true, type: :uuid
      t.string :type
      t.string :node_type
      t.string :root
      t.string :address
      t.text :value
      t.string :klass
      t.string :name
      t.string :struct
      t.string :file
      t.string :line
      t.string :method
      t.integer :generation
      t.integer :size
      t.integer :length
      t.integer :memsize
      t.integer :bytesize
      t.integer :capacity
      t.integer :ivars
      t.integer :fd
      t.string :encoding
      t.string :default_address
      t.boolean :freezed
      t.boolean :fstring
      t.boolean :embedded
      t.boolean :shared
      t.boolean :flag_wb_protected
      t.boolean :flag_old
      t.boolean :flag_long_lived
      t.boolean :flag_marking
      t.boolean :flag_marked

      t.index :address
      t.index :type
      t.index [:klass, :method]
      t.index [:file, :line]
      t.index :size
      t.index :memsize
    end
  end
end
