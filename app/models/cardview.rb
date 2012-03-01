class Cardview < ActiveRecord::Base
  belongs_to :user, :dependent => :destroy
  belongs_to :flashcard, :dependent => :destroy
end
