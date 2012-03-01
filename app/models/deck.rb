class Deck < ActiveRecord::Base
  has_many :flashcards
  belongs_to :user
  
  
  def draw
    min_cards = []
    min_view = self.flashcards.first.cardviews.count
    self.flashcards.each do |card|
      cv = card.cardviews.count
      if cv < min_view
        min_view = cv
        min_cards = []
        min_cards << card
      elsif cv == min_view
        min_cards << card
      end
    end
    return min_cards[rand(min_cards.length)]
  end
    
  
  def orderedCards(current_user)
    views = {}    
    cards = []
    self.flashcards.each_with_index do |card, index|
      last_view = card.cardviews.where(:user_id => current_user.id).last
      if last_view.nil?
        views[card.id] = Time.new - Random.rand(10000)
      else
        views[card.id] = created_at
      end
    end
    views.sort{|a,b| -1*(a[1]<=>b[1])}.each do |pair|
      cards << Flashcard.find(pair[0])
    end
    return cards
  end
  
      
end
