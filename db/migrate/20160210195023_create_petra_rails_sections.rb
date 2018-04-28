# frozen_string_literal: true

class CreatePetraRailsSections < ActiveRecord::Migration
  def change
    create_table :petra_rails_sections do |t|
      t.string :transaction_identifier, :null => false
      t.string :savepoint, :null => false
      t.timestamps null: false
    end

    add_index :petra_rails_sections, [:transaction_identifier, :savepoint], :unique => true, :name => :petra_rails_section_transaction_identifier_savepoint
  end
end
