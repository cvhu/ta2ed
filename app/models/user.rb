class User < ActiveRecord::Base
  has_many :decks
  has_many :quizzes
  
  attr_accessible :email, :password, :password_confirmation, :name
  has_secure_password
  validates_uniqueness_of :email
  validates_presence_of :name, :on => :create
  validates_presence_of :email, :on => :create
  validates_presence_of :password, :on => :create
end
