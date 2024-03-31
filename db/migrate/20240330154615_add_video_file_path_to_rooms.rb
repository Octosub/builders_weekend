class AddVideoFilePathToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :video_filepath, :string
  end
end
