Ta2ed::Application.routes.draw do
  
  resources :decks, :flashcards

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  resources :users
  resources :sessions
  
  get "learn_deck/:id" => "decks#learn", :as => "learn_deck"
  get "/learn_deck/:id/prepare" => "decks#prepareLearn", :as => "prepare_learn_deck"

  # JSON requests
  get "/api/flashcards" => "decks#getFlashcards"
  get "/api/flashcard/create" => "flashcards#postFlashcard"
  get "/api/flashcard/edit" => "flashcards#editFlashcard"
  get "/api/flashcard/remove" => "flashcards#removeFlashcard"
  
  get "/api/deck/edit" => "decks#editDeck"
  
  get "/api/learn" => "decks#learnAPI"
  
  get "/create_state" => "decks#createState"
  get "/create_new_deck" => "decks#createUntitled", :as => "create_new_deck"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'decks#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
