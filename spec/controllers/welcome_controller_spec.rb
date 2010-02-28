require 'spec_helper'

describe WelcomeController do
  describe "GET 'index'" do
    it "should redirect to the network configuration" do
      get 'index'
      response.should redirect_to(network_path)
    end
  end
end
