class CreateAnnotations < ActiveRecord::Migration[7.1]
  def change
    create_table :annotations do |t|
      t.float :lat
      t.float :lon
      t.string :name
      t.text :description
      t.references :map, null: false, foreign_key: true

      t.timestamps
    end
  end
end
