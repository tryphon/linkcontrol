class WelcomeController < ApplicationController

  def index
    redirect_to link_stream_path
  end
  
end
