class CreateImports < ActiveRecord::Migration[5.0]
  def change
    create_table :imports, id: :uuid do |t|
      t.timestamps
    end
  end
end
