class AddUserDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_column :users, :home_address, :string
    add_column :users, :home_lat, :float
    add_column :users, :home_lon, :float
  end
end
