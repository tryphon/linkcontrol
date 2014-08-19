require 'spec_helper'

describe "/networks/show" do

  let!(:network) { assigns[:network] = Network.new(:id => "eth0") }

  it "should display method name" do
    network.stub!(:presenter).and_return(mock(NetworkPresenter, :method_name => "dummy"))
    render 'networks/show'
    response.should have_text(/dummy/)
  end

  context "when network method is static" do

    before(:each) do
      network.method = "static"
    end

    it "should display the static address" do    
      network.static_address = "dummy"
      render 'networks/show'
      response.should have_text(/#{network.static_address}/)
    end

  end

  context "when network method is dhcp" do

    before(:each) do
      network.method = "dhcp"
    end

    it "should display the current address" do    
      network.stub :address => "dummy"
      render 'networks/show'
      response.should have_text(/#{network.address}/)
    end

  end

  it "should display the current id" do    
    network.stub :id => "dummy"
    render 'networks/show'
    response.should have_text(/#{network.id}/)
  end

  it "should display the current mac_address" do    
    network.stub :mac_address => "dummy"
    render 'networks/show'
    response.should have_text(/#{network.mac_address}/)
  end

  it "should display an action to edit the network" do
    render 'networks/show'
    response.should have_tag('a[href=?]', edit_network_path(network))
  end

end
