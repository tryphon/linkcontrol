require 'spec_helper'

describe "/networks/show" do

  before(:each) do
    assigns[:network] = @network = Network.new
  end

  it "should display the static address" do    
    @network.method = "static"
    @network.static_address = "dummy"
    render 'networks/show'
    response.should have_text(/#{@network.static_address}/)
  end

  it "should display an action to edit the network" do
    render 'networks/show'
    response.should have_tag('a[href=?]', edit_network_path)
  end

end
