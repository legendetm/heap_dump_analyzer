class AddGraphsToImports < ActiveRecord::Migration[5.0]
  def change
    add_column :imports, :graphs, :json
  end
end
