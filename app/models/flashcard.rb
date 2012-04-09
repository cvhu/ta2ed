class Flashcard < ActiveRecord::Base
  belongs_to :deck
  has_many :states, :dependent => :destroy
  
  def api
    api = {
      :id => self.id,
      :side_a => self.side_a,
      :side_b => self.side_b
    }
    return api
  end
end
