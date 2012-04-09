class State < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :deck
  belongs_to :flashcard
  
  
  
  # value:
  # 0 => Fullview
  # 1 => Partial Remember
  # 2 => Partial Forgot
  # 3 => Quiz Correct
  # 4 => Quiz Wrong
  
  
  
end
