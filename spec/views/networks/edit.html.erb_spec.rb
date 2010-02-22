require 'spec_helper'

describe "/networks/edit" do

  before(:each) do
    assigns[:network] = @network = Network.new
  end

  it "should display a field for static address" do    
    render 'networks/edit'
    response.should have_tag('input[name=?]', 'network[static_address]')
  end

  it "should display an action to go back to the network path" do
    render 'networks/edit'
    response.should have_tag('a[href=?]', network_path)
  end

end
