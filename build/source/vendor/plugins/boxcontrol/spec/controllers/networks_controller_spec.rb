require 'spec_helper'

describe NetworksController do

  let(:network) { Network.new :id => "eth0" }
  let(:networks) { [ network ] }

  before(:each) do
    network.stub!(:save).and_return(true)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should render index view" do
      get 'index'
      response.should render_template("index")
    end

    it "should define @networks by loading all instances" do
      Network.should_receive(:all).and_return(networks)
      get 'index'
      assigns[:networks].should == networks
    end

  end

  describe "GET 'show'" do

    it "should be successful" do
      get 'show', :id => "eth0"
      response.should be_success
    end

    it "should render show view" do
      get 'show', :id => "eth0"
      response.should render_template("show")
    end

    it "should define @network by find the associated instance" do
      Network.should_receive(:find).with("eth0").and_return(network)
      get 'show', :id => "eth0"
      assigns[:network].should == network
    end

  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit', :id => "eth0"
      response.should be_success
    end

    it "should render edit view" do
      get 'edit', :id => "eth0"
      response.should render_template("edit")
    end

    it "should define @network by load a new instance" do
      Network.should_receive(:find).with("eth0").and_return(network)
      get 'edit', :id => "eth0"
      assigns[:network].should == network
    end

  end

  describe "PUT 'update'" do

    let(:params) { { "dummy" => true } }

    before(:each) do
      Network.stub!(:find).and_return(network)
    end

    it "should find Network instance with id" do
      Network.should_receive(:find).with("eth0").and_return(network)
      put 'update', :id => "eth0"
    end

    it "should update attributes of the Network instance" do
      network.should_receive(:update_attributes).and_return(true)
      put 'update', :id => "eth0"
    end

    describe "when network is successfully saved" do

      before(:each) do
        network.stub!(:update_attributes).and_return(true)
      end
      
      it "should redirect to network path" do
        put 'update', :id => "eth0"
        response.should redirect_to(network_path)
      end

      it "should define a flash notice" do
        put 'update', :id => "eth0"
        flash.should have_key(:success)
      end

    end

    describe "when network isn't saved" do

      before(:each) do
        network.stub!(:update_attributes).and_return(false)
      end
      
      it "should redirect to edit action" do
        post 'update', :id => "eth0"
        response.should render_template("edit")
      end

      it "should define a flash failure" do
        post 'update', :id => "eth0"
        flash.should have_key(:failure)
      end

    end

  end
end
