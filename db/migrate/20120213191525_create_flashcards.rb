class CreateFlashcards < ActiveRecord::Migration
  def change
    create_table :flashcards do |t|
      t.text :side_a
      t.text :side_b
      t.integer :deck_id

      t.timestamps
    end
  end
end
