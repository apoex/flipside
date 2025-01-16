class CreateFlipsideMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :flipside_features do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :enabled, default: false, null: false
      t.datetime :activated_at
      t.datetime :deactivated_at
      t.timestamps
    end

    create_table :flipside_entities do |t|
      t.belongs_to :feature, null: false
      t.bigint :flippable_id, null: false
      t.string :flippable_type, null: false
      t.timestamps
    end

    create_table :flipside_roles do |t|
      t.belongs_to :feature, null: false
      t.string :class_name, null: false
      t.string :method, null: false
      t.timestamps
    end

    add_index :flipside_features, :name, unique: true
  end
end
