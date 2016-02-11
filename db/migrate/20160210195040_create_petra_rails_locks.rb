class CreatePetraRailsLocks < ActiveRecord::Migration
  def change
    create_table :petra_rails_locks do |t|
      t.string   :identifier, :null => false
      t.datetime :taken_at
      t.timestamps null: false
    end
  end
end
