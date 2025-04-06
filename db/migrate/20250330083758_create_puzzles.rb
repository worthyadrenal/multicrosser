class CreatePuzzles < ActiveRecord::Migration[7.1]
  def change
    create_table :puzzles do |t|
      t.string :title
      t.text :grid

      t.timestamps
    end
  end
end
