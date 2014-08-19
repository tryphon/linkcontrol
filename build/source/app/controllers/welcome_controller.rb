class WelcomeController < ApplicationController

  def index
    redirect_to outgoing_stream_path
  end
  
end
