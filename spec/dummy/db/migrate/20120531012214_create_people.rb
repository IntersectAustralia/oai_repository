class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :key
      t.string :title
      t.string :given_name
      t.string :family_name
      t.string :organisation
      t.string :email

      t.timestamps
    end
  end
end
