class Flashcard < ActiveRecord::Base
  belongs_to :deck, :dependent => :destroy
  has_many :cardviews
  has_many :quizzes
end
