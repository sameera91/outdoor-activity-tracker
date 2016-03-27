class User < ActiveRecord::Base
  has_many :locations
  has_many :activities
  has_many :locations, through: :user_locations
  has_secure_password
end
