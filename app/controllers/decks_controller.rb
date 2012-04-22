class DecksController < ApplicationController
  # GET /decks
  # GET /decks.json
  def index
    if current_user
      @decks = Deck.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @decks }
      end
    else
      redirect_to :signup
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
  
  class LearnHelper
    attr_accessor :deck, :mode, :partial_flag, :quiz_count, :type, :front, :explored, :attachment
    def fullView      
      candidates = @deck.flashcards.map{|x| x.id} - (@front + @explored)
      if candidates.length==0
        if @partial_flag == 0
          self.partialView()
        else
          self.quizView()
        end
      else
        x = candidates[rand(candidates.length)]
        @front.push(x)
        @attachment[:flashcard] = Flashcard.find(x)
        @type = 'full'               
      end
    end
    
    def partialView
      @attachment[:flashcards] = @front[0..2].map{|x| Flashcard.find(x)}
      @type = 'partial'
      @partial_flag = 1
    end
    
    def quizView
      @type = 'quiz'
      @quiz = {}
      @quiz_count += 1
      ans = @front[0..2]
      que = ans[rand(ans.length)]
      while ans.length <3
        candidates = @deck.flashcards.map{|x| x.id} - ans
        ans = ans + [candidates[rand(candidates.length)]]
      end
      
      @front = @front - [que]
      @quiz[:question_id] = que
      @quiz[:question] = Flashcard.find(que).side_a
      @quiz[:answer] = Flashcard.find(que).side_b
      @quiz[:correct_url] = "/create_state.json?flashcard_id=#{que}&deck_id=#{@deck.id}&value=3"
      @quiz[:wrong_url] = "/create_state.json?flashcard_id=#{que}&deck_id=#{@deck.id}&value=4"
      @quiz[:choices] = ans.map{|x| Flashcard.find(x).side_b}
      @attachment[:quiz] = @quiz
      if @quiz_count >=2
        @partial_flag = 0
      end
    end
    
    def quizOnlyHelp
      candidates = @deck.flashcards.map{|x| x.id} - (@front + @explored)
      unless candidates.length==0
        x = candidates[rand(candidates.length)]
        @front.push(x)
      end
    end
    
    def getData
      @data = {}
      @data[:type] = @type
      @data[:front] = @front
      @data[:explored] = @explored
      @data[:partial_flag] = @partial_flag
      @data[:quiz_count] = @quiz_count
      @data[:attachment] = @attachment
      @partial_flag = 0
      return @data
    end
    
  end
  
  def learnAPI
    lh = LearnHelper.new
    lh.deck = Deck.find(params[:deck_id])
    lh.mode = params[:mode]
    lh.partial_flag = params[:partial_flag].to_i
    lh.quiz_count = params[:quiz_count].to_i
    if params[:front].nil?
      lh.front = []
    else
      lh.front = params[:front].map{|x| x.to_i}
    end
    if params[:explored].nil?
      lh.explored = []
    else
      lh.explored = params[:explored].map{|x| x.to_i}
    end
    lh.type = 'error'
    lh.attachment = {}
    
    
    if lh.mode=='standard'
      if (lh.front.length<3)
        lh.fullView()      
      else
        if lh.quiz_count <2
          if lh.partial_flag == 0
            lh.partialView()
          else
            lh.quizView()
          end
        else
          lh.quiz_count = 0
          lh.fullView()
        end
      end
    elsif lh.mode=='quiz_only'
      lh.quizOnlyHelp()
      lh.quizView()
    end
    respond_to do |format|
      format.json {render :json => lh.getData().to_json}
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
