class WelcomeController < ApplicationController

  def index
    redirect_to network_path
  end
  
end
