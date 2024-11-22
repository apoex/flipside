class CreateFlipsideMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :flipside_features do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :enabled, default: false, null: false
      t.string :type
      t.string :method
      t.datetime :activated_at
      t.datetime :deactivated_at
      t.timestamps
    end

    create_table :flipside_entities do |t|
      t.belongs_to :feature
      t.bigint :flippable_id
      t.string :flippable_type
      t.timestamps
    end

    add_index :flipside_features, :name, unique: true
  end
end
