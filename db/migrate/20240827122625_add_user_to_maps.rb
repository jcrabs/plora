class AddUserToMaps < ActiveRecord::Migration[7.1]
  def change
    add_reference :maps, :user, null: false, foreign_key: true
  end
end



