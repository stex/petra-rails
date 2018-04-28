# frozen_string_literal: true

class CreatePetraRailsSections < ActiveRecord::Migration
  def change
    create_table :petra_rails_sections do |t|
      t.string :transaction_identifier, null: false
      t.string :savepoint, null: false
      t.timestamps null: false
    end

    add_index :petra_rails_sections, %i[transaction_identifier savepoint], unique: true
  end
end
