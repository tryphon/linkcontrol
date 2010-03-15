require 'spec_helper'

describe WelcomeController do
  describe "GET 'index'" do
    it "should redirect to the LinkStream configuration" do
      get 'index'
      response.should redirect_to(link_stream_path)
    end
  end
end
