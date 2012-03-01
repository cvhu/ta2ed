class FlashcardsController < ApplicationController
  # GET /flashcards
  # GET /flashcards.json
  def index
    @flashcards = Flashcard.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @flashcards }
    end
  end

  # GET /flashcards/1
  # GET /flashcards/1.json
  def show
    @flashcard = Flashcard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @flashcard }
    end
  end

  # GET /flashcards/new
  # GET /flashcards/new.json
  def new
    @flashcard = Flashcard.new
    @deck = Deck.find(params[:deck_id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @flashcard }
    end
  end

  # GET /flashcards/1/edit
  def edit
    @flashcard = Flashcard.find(params[:id])
  end

  # POST /flashcards
  # POST /flashcards.json
  def create
    
    @flashcard = Flashcard.new(params[:flashcard])
    @deck = Deck.find(params[:deck_id])   
    @flashcard.deck = @deck
    respond_to do |format|
      if @flashcard.save
        format.html { redirect_to @deck, notice: 'Flashcard was successfully created.' }
        format.json { render json: @flashcard, status: :created, location: @flashcard }
      else
        format.html { render action: "new" }
        format.json { render json: @flashcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /flashcards/1
  # PUT /flashcards/1.json
  def update
    @flashcard = Flashcard.find(params[:id])

    respond_to do |format|
      if @flashcard.update_attributes(params[:flashcard])
        format.html { redirect_to @flashcard, notice: 'Flashcard was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @flashcard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /flashcards/1
  # DELETE /flashcards/1.json
  def destroy
    @flashcard = Flashcard.find(params[:id])
    @flashcard.destroy

    respond_to do |format|
      format.html { redirect_to flashcards_url }
      format.json { head :ok }
    end
  end
end
