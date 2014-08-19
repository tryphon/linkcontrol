require 'spec_helper'

describe "/networks/edit" do

  let!(:network) { assigns[:network] = Network.new(:id => "eth0") }

  it "should display a field for static address" do    
    render 'networks/edit'
    response.should have_tag('input[name=?]', 'network[static_address]')
  end

  it "should display an action to go back to the network path" do
    render 'networks/edit'
    response.should have_tag('a[href=?]', network_path(network))
  end

  it "should display a radio button to select static method" do
    render 'networks/edit'
    response.should have_tag('input[type=radio][value=static][name=?]','network[method]')
  end

  it "should display a label for static method radio button with NetworkPresentation static method name" do
    NetworkPresenter.stub!(:static_method_name).and_return("static_method_name")
    render 'networks/edit'
    response.should have_tag('label','static_method_name')
  end

  it "should display a radio button to select dhcp method" do
    render 'networks/edit'
    response.should have_tag('input[type=radio][value=dhcp][name=?]','network[method]')
  end

  it "should display a label for dhcp method radio button with NetworkPresentation dhcp method name" do
    NetworkPresenter.stub!(:dhcp_method_name).and_return("dhcp_method_name")
    render 'networks/edit'
    response.should have_tag('label','dhcp_method_name')
  end

end
