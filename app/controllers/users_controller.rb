class UsersController < ApplicationController
  def new
  end

  def create
  end
  
  def show
    render json: current_user
  end
end
