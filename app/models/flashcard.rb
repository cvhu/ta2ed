class Flashcard < ActiveRecord::Base
  belongs_to :deck, :dependent => :destroy
  has_many :cardviews
  has_many :quizzes
  
  def api
    api = {
      :side_a => self.side_a,
      :side_b => self.side_b,
      :views => self.cardviews.count
    }
    return api
  end
end
