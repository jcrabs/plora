class CreatePointOfInterests < ActiveRecord::Migration[7.1]
  def change
    create_table :point_of_interests do |t|
      t.string :name
      t.string :category
      t.text :description
      t.float :lat
      t.float :lon
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
