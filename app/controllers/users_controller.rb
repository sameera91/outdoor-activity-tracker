class UsersController < ApplicationController

  get '/signup' do
    erb :"users/create_user", :layout => false
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
      erb :"users/login", :layout => false
    end
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
       session[:user_id] = @user.id
       redirect "/locations"
     else
       erb :"users/login", :layout => false, :locals => {:message => "Invalid username or password! Please try again."}
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

end