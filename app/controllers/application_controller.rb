require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
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
    @activity = Activity.create(name: params[:name], time: params[:time], distance: params[:distance])
    @activity.location = Location.create(name: params[:location])
    @activity.save
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
      redirect '/activities'
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
       erb :"users/login", locals: {message: "Invalid username or password! Please try again."}
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
    erb :"activities/activities"
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
    @location = Location.create(params)
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
    redirect "/locations/#{@location.id}"
  end

  delete '/locations/:id/delete' do
    @location = Location.find_by(id: params[:id])
    @location.delete
    erb :"locations/locations"
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