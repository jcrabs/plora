class CreateSegments < ActiveRecord::Migration[7.1]
  def change
    create_table :segments do |t|
      t.references :map, null: false, foreign_key: true

      t.timestamps
    end
  end
end
