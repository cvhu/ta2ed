class LearningController < ApplicationController
  
  def memorize
    @deck = Deck.find(params[:deck_id])
    oc = @deck.orderedCards(current_user)
    last_quiz = current_user.quizzes.last
    # if last_quiz.nil?
    if false #.created_at < oc[1].cardviews.last.created_at
      redirect_to quiz_path
    else      
      unless params[:flashcard_id].nil?
        @flashcard = Flashcard.find(params[:flashcard_id])
        if oc.index(@flashcard)-1 < 0
          @flashcard_prev = nil
        else
          @flashcard_prev = oc[oc.index(@flashcard)-1]
        end
      else
        @flashcard = @deck.orderedCards(current_user).last
        @cardview = Cardview.new(:user_id => current_user.id, :flashcard_id => @flashcard.id)
        @cardview.save        
        @flashcard_prev = oc[0]
      end      
      respond_to do |format|
        format.html
      end
    end
  end
  
  def quiz
  end
  
end
