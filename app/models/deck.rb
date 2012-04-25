class Deck < ActiveRecord::Base
  has_many :flashcards, :dependent => :destroy
  has_many :states, :dependent => :destroy
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
          @quiz[:question_id] = flashcard.id
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
  
  # User profiles
  
  def masters
    m = []
    self.states.group_by(&:user_id).each do |user_id, u_states|
      scores = []
      self.flashcards.each do |flashcard|
        scores << flashcard.score(user_id)
      end
      user = User.find(user_id)
      m << {:user => {:id => user.id, :name => user.name}, :score =>scores.sum.to_f/scores.count, :last_session => u_states.last.created_at}
    end
    return m
  end
end
