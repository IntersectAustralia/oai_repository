class CreateInstruments < ActiveRecord::Migration
  def change
    create_table :instruments do |t|
      t.string :key
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
