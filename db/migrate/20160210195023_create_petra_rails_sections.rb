# frozen_string_literal: true

class CreatePetraRailsSections < ActiveRecord::Migration[4.2]
  def change
    create_table :petra_rails_sections do |t|
      t.string :transaction_identifier, null: false
      t.string :savepoint, null: false
      t.timestamps null: false
    end

    add_index :petra_rails_sections,
              %i[transaction_identifier savepoint],
              unique: true,
              name:   'index_petra_rails_sections'
  end
end
