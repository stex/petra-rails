# frozen_string_literal: true

class CreatePetraRailsLogEntries < ActiveRecord::Migration
  def change
    create_table :petra_rails_log_entries do |t|
      t.belongs_to :section
      t.text :fields

      t.timestamps null: false
    end
  end
end
