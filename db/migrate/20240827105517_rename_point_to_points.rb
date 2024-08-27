class RenamePointToPoints < ActiveRecord::Migration[7.1]
  def change
    rename_table :explored_point_of_interests, :explored_points_of_interest
  end
end
