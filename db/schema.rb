# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161123184318) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "heap_dumps", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "import_id"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_heap_dumps_on_import_id", using: :btree
  end

  create_table "imports", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json     "graphs"
  end

  create_table "space_object_references", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid   "from_id",    null: false
    t.string "to_address", null: false
  end

  create_table "space_objects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid    "heap_dump_id"
    t.string  "type"
    t.string  "node_type"
    t.string  "root"
    t.string  "address"
    t.text    "value"
    t.string  "klass"
    t.string  "name"
    t.string  "struct"
    t.string  "file"
    t.string  "line"
    t.string  "method"
    t.integer "generation"
    t.integer "size"
    t.integer "length"
    t.integer "memsize"
    t.integer "bytesize"
    t.integer "capacity"
    t.integer "ivars"
    t.integer "fd"
    t.string  "encoding"
    t.string  "default_address"
    t.boolean "freezed"
    t.boolean "fstring"
    t.boolean "embedded"
    t.boolean "shared"
    t.boolean "flag_wb_protected"
    t.boolean "flag_old"
    t.boolean "flag_long_lived"
    t.boolean "flag_marking"
    t.boolean "flag_marked"
    t.index ["address"], name: "index_space_objects_on_address", using: :btree
    t.index ["file", "line"], name: "index_space_objects_on_file_and_line", using: :btree
    t.index ["heap_dump_id"], name: "index_space_objects_on_heap_dump_id", using: :btree
    t.index ["klass", "method"], name: "index_space_objects_on_klass_and_method", using: :btree
    t.index ["memsize"], name: "index_space_objects_on_memsize", using: :btree
    t.index ["size"], name: "index_space_objects_on_size", using: :btree
    t.index ["type"], name: "index_space_objects_on_type", using: :btree
  end

  add_foreign_key "heap_dumps", "imports"
  add_foreign_key "space_objects", "heap_dumps"
end
