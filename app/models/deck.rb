class Deck < ActiveRecord::Base
  has_many :flashcards
  has_many :states
  belongs_to :user, :dependent => :destroy
  
  
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

  def last_draw(user_id)
    @drawed = []
    2.times.each do |i|
      state = self.states.where(:user_id => user_id).where(:value => 0)[-(i+1)]
      unless state.nil?
        @drawed << state.flashcard
      end
    end
    return @drawed
  end
  
  def full_draw(user_id)    
    @flashcards = []
    self.flashcards.each do |flashcard|
      if flashcard.states.empty?
        @flashcards << flashcard
      elsif not self.last_draw(user_id).include?(flashcard)
        @flashcards << flashcard
      end
    end
    @flashcard = @flashcards[rand(@flashcards.length)]
    @state = State.new
    @state.user_id = user_id
    @state.deck = self    
    @state.flashcard = @flashcard
    @state.value = 0
    @state.save    
    return @flashcard
  end
  
  def partial_draw(user_id)
    flashcards = []
    3.times.each do |i|
      flashcard = self.states.where(:user_id => user_id).where(:value => 0)[-(i+1)].flashcard
      logger.debug "=========== PARTIALVIEW: #{-(i+1)}"
      @state = State.new
      @state.user_id = user_id
      @state.deck = self
      @state.flashcard = flashcard
      @state.value = 1
      @state.save
      flashcards << flashcard
    end
    return flashcards
  end
  
  def quiz_draw(user_id)
    @quiz = {:choices => []}
    r = rand(3)
    3.times.each do |i|
      flashcard = self.states.where(:user_id => user_id).where(:value => 0)[-(i+1)].flashcard
      unless flashcard.nil?
        if i==r
          @quiz[:question] = flashcard.side_a
          @quiz[:answer] = flashcard.side_b
          @quiz[:correct_url] = "/create_state.json?flashcard_id=#{flashcard.id}&deck_id=#{self.id}&value=3"
          @quiz[:wrong_url] = "/create_state.json?flashcard_id=#{flashcard.id}&deck_id=#{self.id}&value=4"
        end
        @quiz[:choices] << flashcard.side_b
      end
    end    
    return @quiz
  end
end
