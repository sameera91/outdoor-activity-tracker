class LocationsController < ApplicationController

  get '/locations/new' do
    erb :"locations/create_location"
  end

  get '/locations' do
    erb :"locations/locations"
  end

  get '/locations/all_locations' do
    erb :"locations/all_locations"
  end

  post '/locations' do
    if !Location.where(:name => params[:name]).exists? || !current_user.locations.any?{|location| location.name == params[:name]}
      @location = Location.find_or_create_by(name: params[:name], city: params[:city], state: params[:state], country: params[:country])
      current_user.locations << @location unless current_user.locations.include?(@location)
      @location.users << current_user unless @location.users.include?(current_user)
      flash[:success] = "Location successfully added."
    else
      flash[:failure] = "Location already exists. Select location from the list and add a new activity."
    end
    erb :"locations/locations"
  end

  get '/locations/:id/edit' do
    @location = Location.find_by(id: params[:id])
    erb :"locations/edit_location"
  end

  patch '/locations/:id' do
      @location = current_user.locations.find_by(id: params[:id])
    if !Location.where(:name => params[:name]).exists? || !current_user.locations.any?{|location| location.name == params[:name]}
      @location.update(name: params[:name], city: params[:city], state: params[:state], country: params[:country])
      flash[:edited] = "Location successfully edited."
    elsif Location.where(:name => params[:name]).exists? && !current_user.locations.any?{|location| location.name == params[:name]}
      current_user.locations << Location.find_by(name: params[:name])
    else
      flash[:failure] = "Location already exists."
    end
    redirect "/locations/#{@location.id}"
  end

  delete '/locations/:id/delete' do
    @location = Location.find_by(id: params[:id])
    Activity.delete_all(location_id: @location.id)
    @location.users.delete(current_user)
    current_user.locations.delete(@location)
    flash[:deleted] = "Location and all associated activities have been deleted."
    redirect '/locations'
  end

  get '/locations/:id' do
    @location = Location.find(params[:id])
    erb :"locations/show_location"
  end

  get '/locations/all_locations/:id' do
    @location = Location.find(params[:id])
    erb :"locations/users_location"
  end

end