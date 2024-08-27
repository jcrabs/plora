class RenameExploredPointToPoints < ActiveRecord::Migration[7.1]
  def change
    rename_table :point_of_interests, :points_of_interest
  end
end
