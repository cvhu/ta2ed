class DecksController < ApplicationController
  # GET /decks
  # GET /decks.json
  def index
    @decks = Deck.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  # GET /decks/1
  # GET /decks/1.json
  def show
    @deck = Deck.find(params[:id])
    @flashcards = @deck.flashcards
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/new
  # GET /decks/new.json
  def new
    @deck = Deck.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/1/edit
  def edit
    @deck = Deck.find(params[:id])
  end

  # POST /decks
  # POST /decks.json
  def create
    @deck = Deck.new(params[:deck])
    @deck.user = current_user
    respond_to do |format|
      if @deck.save
        format.html { redirect_to @deck, notice: 'Deck was successfully created.' }
        format.json { render json: @deck, status: :created, location: @deck }
      else
        format.html { render action: "new" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /decks/1
  # PUT /decks/1.json
  def update
    @deck = Deck.find(params[:id])

    respond_to do |format|
      if @deck.update_attributes(params[:deck])
        format.html { redirect_to @deck, notice: 'Deck was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /decks/1
  # DELETE /decks/1.json
  def destroy
    @deck = Deck.find(params[:id])
    @deck.destroy

    respond_to do |format|
      format.html { redirect_to decks_url }
      format.json { head :ok }
    end
  end
  
  
  def learn
    @deck = Deck.find(params[:id])
    last_state = @deck.states.where(:user_id => current_user.id).last
    if last_state.nil?
      logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 1"
      @flashcard = @deck.full_draw(current_user.id)
      render :full
    elsif last_state.value == 0
      last2_state = @deck.states.where(:user_id => current_user.id)[-2]
      if last2_state.nil?
        logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 2"
        @flashcard = @deck.full_draw(current_user.id)
        render :full
      elsif last2_state.value == 0
        last3_state = @deck.states.where(:user_id => current_user.id)[-3]
        if last3_state.nil?
          logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 3"
          @flashcard = @deck.full_draw(current_user.id)
          render :full
        elsif last3_state.value == 0
          logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% partialview"
          @flashcards = @deck.partial_draw(current_user.id)
          render :partial
        else
          logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 2"
          @flashcard = @deck.full_draw(current_user.id)
          render :full
        end
      else
        logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 3"
        @flashcard = @deck.full_draw(current_user.id)
        render :full
      end
    elsif last_state.value == 1 or last_state.value == 2
      logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% quizview"
      @quiz = @deck.quiz_draw(current_user.id)
      render :quiz
    elsif last_state.value == 3 or last_state.value == 4
      logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 1"
      @flashcard = @deck.full_draw(current_user.id) 
      render :full
    end
    
  end
  
  def prepareLearn
    @deck = Deck.find(params[:id])
  end
      
  
  # ==============================   JSON Requests ==============================
  def getFlashcards
    @deck = Deck.find(params[:deck_id])
    @flashcards = @deck.flashcards.order("created_at DESC")
    respond_to do |format|
      format.json {render :json => apis(@flashcards).to_json}
    end
  end
  
  
  def learnAPI
    @deck = Deck.find(params[:deck_id])
    last_state = @deck.states.where(:user_id => current_user.id).last
    if last_state.nil?
      logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 1"
      @flashcard = @deck.full_draw(current_user.id)
      render :full
    elsif last_state.value == 0
      last2_state = @deck.states.where(:user_id => current_user.id)[-2]
      if last2_state.nil?
        logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 2"
        @flashcard = @deck.full_draw(current_user.id)
        render :full
      elsif last2_state.value == 0
        last3_state = @deck.states.where(:user_id => current_user.id)[-3]
        if last3_state.nil?
          logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 3"
          @flashcard = @deck.full_draw(current_user.id)
          render :full
        elsif last3_state.value == 0
          logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% partialview"
          @flashcards = @deck.partial_draw(current_user.id)
          render :partial
        else
          logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 2"
          @flashcard = @deck.full_draw(current_user.id)
          render :full
        end
      else
        logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 3"
        @flashcard = @deck.full_draw(current_user.id)
        render :full
      end
    elsif last_state.value == 1 or last_state.value == 2
      logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% quizview"
      @quiz = @deck.quiz_draw(current_user.id)
      render :quiz
    elsif last_state.value == 3 or last_state.value == 4
      logger.debug "%%%%%%%%%%%%%%%%%%%%%%%%% fullview 1"
      @flashcard = @deck.full_draw(current_user.id) 
      render :full
    end
    
  end
  
  
  def apis(flashcards)
    apis = []
    flashcards.each do |flashcard|
      apis << flashcard.api
    end
    return apis
  end
  
  def createState
    @state = State.new
    @state.user_id = current_user.id
    @state.deck_id = params[:deck_id]
    @state.flashcard_id = params[:flashcard_id]
    @state.value = params[:value]
    @state.save
    respond_to do |format|
      format.json {render :json => @state.to_json}
    end
  end
  
end
