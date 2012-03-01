class CreateCardviews < ActiveRecord::Migration
  def change
    create_table :cardviews do |t|
      t.integer :user_id
      t.integer :flashcard_id
      t.timestamps
    end
  end
end
