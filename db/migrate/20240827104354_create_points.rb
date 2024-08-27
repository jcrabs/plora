class CreatePoints < ActiveRecord::Migration[7.1]
  def change
    create_table :points do |t|
      t.float :lat
      t.float :lon
      t.references :segment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
