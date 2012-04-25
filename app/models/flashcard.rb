class Flashcard < ActiveRecord::Base
  belongs_to :deck
  has_many :states, :dependent => :destroy
  
  def api(user_id)
    api = {
      :id => self.id,
      :side_a => self.side_a,
      :side_b => self.side_b,
      :score => self.score(user_id)
    }
    return api
  end
  
  
  def score(user_id)    
    states = self.states.where(:user_id => user_id)
    if states.empty?()
      score = 0.0
    else
      values = {3 => 0, 4 => 0}
      states.each do |state|
        if values.keys().include?(state.value)
          values[state.value] += 1
        else
          values[state.value] = 1
        end
      end      
      score = (values[3]+0.0)/(values[3]+values[4])
    end    
    return score
  end
end
