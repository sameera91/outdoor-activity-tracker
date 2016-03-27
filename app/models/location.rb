class Location < ActiveRecord::Base
  has_many :activities
  has_many :users, through: :user_locations
end