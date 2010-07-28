require 'spec_helper'

describe LinkStreamsController do

  before(:each) do
    @link_stream = LinkStream.new
    @link_stream.stub :save => true
  end

  describe "GET 'show'" do
    it "should be successful" do
      get 'show'
      response.should be_success
    end

    it "should render show view" do
      get 'show'
      response.should render_template("show")
    end

    it "should define @link_stream by load a new instance" do
      LinkStream.should_receive(:load).and_return(@link_stream)
      get 'show'
      assigns[:link_stream].should == @link_stream
    end

  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end

    it "should render edit view" do
      get 'edit'
      response.should render_template("edit")
    end

    it "should define @link_stream by load a new instance" do
      LinkStream.should_receive(:load).and_return(@link_stream)
      get 'edit'
      assigns[:link_stream].should == @link_stream
    end

  end

  describe "PUT 'update'" do

    before(:each) do
      @params = { "dummy" => true }
      LinkStream.stub!(:new).and_return(@link_stream)
    end

    it "should create a LinkStream instance with form attributes" do
      LinkStream.should_receive(:new).and_return(@link_stream)
      @link_stream.should_receive(:update_attributes).with(@params)
      post 'update', :link_stream => @params
    end

    it "should save the LinkStream instance" do
      @link_stream.should_receive(:save).and_return(true)
      post 'update'
    end

    describe "when link_stream is successfully saved" do

      before(:each) do
        @link_stream.stub!(:save).and_return(true)
      end
      
      it "should redirect to link_stream path" do
        post 'update'
        response.should redirect_to(link_stream_path)
      end

      it "should define a flash notice" do
        post 'update'
        flash.should have_key(:success)
      end

    end

    describe "when link_stream isn't saved" do

      before(:each) do
        @link_stream.stub!(:save).and_return(false)
      end
      
      it "should redirect to edit action" do
        post 'update'
        response.should render_template("edit")
      end

      it "should define a flash failure" do
        post 'update'
        flash.should have_key(:failure)
      end

    end

  end

end
