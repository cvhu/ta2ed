class DropQuizzesAndcardviews < ActiveRecord::Migration
  def up
    drop_table :quizzes
    drop_table :cardviews
  end

  def down
  end
end
