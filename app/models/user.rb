class User < ActiveRecord::Base
  has_many :decks, :dependent => :destroy
  has_many :states, :dependent => :destroy
  
  attr_accessible :email, :password, :password_confirmation, :name
  has_secure_password
  validates_uniqueness_of :email
  validates_presence_of :name, :on => :create
  validates_presence_of :email, :on => :create
  validates_presence_of :password, :on => :create
  
  def learnings
    m = []
    self.states.group_by(&:deck_id).each do |deck_id, u_states|
      scores = []
      deck = Deck.find(deck_id)
      deck.flashcards.each do |flashcard|
        scores << flashcard.score(self.id)
      end
      m << {:deck => {:id => deck.id, :title => deck.title}, :score =>scores.sum.to_f/scores.count, :last_session => u_states.last.created_at}
    end
    return m
  end
  
end
