# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_25_161327) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.string "inci_name"
    t.string "reading", null: false
    t.integer "caution_level", null: false
    t.string "category", null: false
    t.string "purpose", null: false
    t.text "description"
    t.string "source"
    t.string "source_url"
    t.date "source_accessed_on"
    t.boolean "ai_generated", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
    t.check_constraint "caution_level >= 1 AND caution_level <= 5", name: "ingredients_caution_level_range"
  end
end
