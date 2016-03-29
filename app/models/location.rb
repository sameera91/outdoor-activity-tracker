class Location < ActiveRecord::Base
  has_many :activities
  has_many :user_locations
  has_many :users, through: :user_locations
end