class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.integer :user_id
      t.integer :deck_id
      t.integer :flashcard_id
      t.integer :value

      t.timestamps
    end
  end
end
