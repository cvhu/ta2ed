class State < ActiveRecord::Base
  
  belongs_to :user, :dependent => :destroy
  belongs_to :deck, :dependent => :destroy
  belongs_to :flashcard, :dependent => :destroy
  
  
  
  # value:
  # 0 => Fullview
  # 1 => Partial Remember
  # 2 => Partial Forgot
  # 3 => Quiz Correct
  # 4 => Quiz Wrong
  
  
  
end
