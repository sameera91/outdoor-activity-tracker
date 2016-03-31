class ActivitiesController < ApplicationController

  get '/activities/new' do
    erb :"activities/create_activity"
  end

  get '/activities' do
    erb :"activities/activities"
  end

  post '/activities' do
    @activity = Activity.create(name: params[:name], date: params[:date], time: params[:time], distance: params[:distance], :user_id => current_user.id)
    @activity.location = Location.create(name: params[:location])
    @activity.save
    current_user.activities << @activity
    flash[:notice] = "Activity successfully added."
    redirect '/activities'
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
    @activity.update(name: params[:name], date: params[:date], time: params[:time], distance: params[:distance], notes: params[:notes], :user_id => current_user.id)

    flash[:notice] = "Activity successfully edited."
    redirect "/activities/#{@activity.id}"
  end

end