require 'test_helper'

class FlashcardsControllerTest < ActionController::TestCase
  setup do
    @flashcard = flashcards(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flashcards)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flashcard" do
    assert_difference('Flashcard.count') do
      post :create, flashcard: @flashcard.attributes
    end

    assert_redirected_to flashcard_path(assigns(:flashcard))
  end

  test "should show flashcard" do
    get :show, id: @flashcard.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @flashcard.to_param
    assert_response :success
  end

  test "should update flashcard" do
    put :update, id: @flashcard.to_param, flashcard: @flashcard.attributes
    assert_redirected_to flashcard_path(assigns(:flashcard))
  end

  test "should destroy flashcard" do
    assert_difference('Flashcard.count', -1) do
      delete :destroy, id: @flashcard.to_param
    end

    assert_redirected_to flashcards_path
  end
end
