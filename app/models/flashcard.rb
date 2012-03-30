class Flashcard < ActiveRecord::Base
  belongs_to :deck, :dependent => :destroy
  has_many :states
  
  def api
    api = {
      :side_a => self.side_a,
      :side_b => self.side_b,
    }
    return api
  end
end
