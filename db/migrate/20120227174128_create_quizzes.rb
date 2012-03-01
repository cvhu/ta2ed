class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.integer :user_id
      t.integer :flashcard_id
      t.boolean :is_correct

      t.timestamps
    end
  end
end
