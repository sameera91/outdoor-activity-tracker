require './config/environment'
require 'sinatra/base'
require 'sinatra/flash'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
    register Sinatra::Flash
  end

  get '/' do
    erb :homepage
  end

  get '/activities/new' do
    erb :"activities/create_activity"
  end

  get '/activities' do
    erb :"activities/activities"
  end

  post '/activities' do
    @activity = Activity.create(name: params[:name], date: params[:date], time: params[:time], distance: params[:distance])
    @activity.location = Location.find_or_create_by(name: params[:location])
    @activity.save
    flash[:notice] = "Activity successfully added."
    redirect '/activities'
  end

  get '/signup' do
    erb :"users/create_user"
  end

  post '/signup' do
      if params[:username] != "" && params[:email] != "" && params[:password] != ""
        @user = User.create(username: params[:username], email: params[:email], password: params[:password])
        session[:user_id] = @user.id
        redirect '/locations'
      else
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

  get '/activities/:id' do
    @activity = Activity.find(params[:id])
    erb :"activities/show_activity"
  end

  delete '/activities/:id/delete' do
    @activity = Activity.find_by(id: params[:id])
    @activity.delete
    flash[:notice] = "Activity successfully deleted."
    redirect '/activities'
  end

  get '/activities/:id/edit' do
    @activity = Activity.find_by(id: params[:id])
    erb :"activities/edit_activity"
  end

  patch '/activities/:id' do
    @activity = Activity.find(params[:id])
    @activity.name = params["name"] if params["name"] != ''
    @activity.time = params["time"] if params["time"] != ''
    @activity.distance = params["distance"] if params["distance"] != ''
    @activity.notes = params["notes"] if params["notes"] != ''
    @activity.save
    flash[:notice] = "Activity successfully edited."
    redirect "/activities/#{@activity.id}"
  end

  get '/locations/new' do
    erb :"locations/create_location"
  end

  get '/locations' do
    erb :"locations/locations"
  end

  get '/locations/:id' do
    @location = Location.find(params[:id])
    erb :"locations/show_location"
  end

  post '/locations' do
    if !Location.where(:name => params[:name]).exists?
      @location = Location.create(params)
      flash[:message] = "Location successfully added."
    else
      flash[:message] = "Location already exists. Select location from the list and add a new activity."
    end
    erb :"locations/locations"
  end

  get '/locations/:id/edit' do
    @location = Location.find_by(id: params[:id])
    erb :"locations/edit_location"
  end

  patch '/locations/:id' do
    @location = Location.find(params[:id])
    @location.name = params["name"] if params["name"] != ''
    @location.city = params["city"] if params["city"] != ''
    @location.state = params["state"] if params["state"] != ''
    @location.country = params["country"] if params["country"] != ''
    @location.save
    flash[:notice] = "Location successfully edited."
    redirect "/locations/#{@location.id}"
  end

  delete '/locations/:id/delete' do
    @location = Location.find_by(id: params[:id])
    Activity.delete_all(location_id: @location.id)
    @location.delete
    flash[:notice] = "Location and all associated activities have been deleted."
    erb :"locations/locations"
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