require './config/environment'
require 'sinatra/base'
require 'sinatra/flash'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    #enable :sessions
    use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'your_secret'
    set :session_secret, "password_security"
    register Sinatra::Flash
  end


  get '/' do
    erb :homepage
  end



  get '/signup' do
    erb :"users/create_user"
  end

  post '/signup' do
      if !User.where(:username => params[:username]).exists?
        @user = User.create(username: params[:username], email: params[:email], password: params[:password])
        session[:user_id] = @user.id
        redirect '/locations'
      else
        flash[:message] = "Username already exists. Try again."
        redirect '/signup'
      end
  end

  get '/login' do
    if is_logged_in
      redirect '/locations'
    else
      erb :"users/login"
    end
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
       session[:user_id] = @user.id
       redirect "/locations"
     else
       erb :"users/login", :locals => {:message => "Invalid username or password! Please try again."}
     end
  end

  get "/logout" do
    if is_logged_in
      session.clear
      redirect '/login'
    else
      redirect "/"
    end
  end





  get '/users/:id' do
    @user = User.find_by(id: params[:id])
    erb :"users/show_user"
  end

  get '/users/:id/edit' do
    @user = User.find_by(id: params[:id])
    if is_logged_in
      erb :"users/edit_user"
    else
      erb :"users/login"
    end
  end

  patch '/users/:id' do
    @user = User.find(params[:id])
    @user.username = params["username"] if params["username"] != ''
    @user.email = params["email"] if params["email"] != ''
    @user.password = params["password"] if params["password"] != ''
    @user.save
    redirect "/users/#{@user.id}"
  end

  delete '/users/:id/delete' do
    @user = User.find_by(id: params[:id])
    @user.delete
    session.clear
    erb :"users/create_user", locals: {message: "Your account has been deleted."}
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