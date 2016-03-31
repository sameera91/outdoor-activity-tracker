require './config/environment'
require 'sinatra/base'
require 'sinatra/flash'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    #enable :sessions
    use Rack::Session::Cookie, :key => 'rack.session', :path => '/', :secret => 'your_secret'
    set :session_secret, "password_security"
    register Sinatra::Flash
  end

  get '/' do
    erb :homepage, :layout => false
  end

  helpers do
    def is_logged_in
      !!session[:user_id]
    end

    def current_user
      User.find_by_id(session[:user_id])
    end
  end

end