require 'spec_helper'

describe ReleasesController do

  let(:release) { Box::Release.new }

  describe "GET 'index'" do

    before do
      Box::Release.stub :current => stub('current')
      Box::Release.stub :latest => stub('latest', :newer? => true)
    end
    
    it "should be successful" do
      get 'index'
      response.should be_success
    end

    it "should assign @current with Box::Release.current" do
      get 'index'
      assigns[:current].should == Box::Release.current
    end

    it "should assign @latest with Box::Release.latest" do
      get 'index'
      assigns[:latest].should == Box::Release.latest
    end

    it "should not assign @latest with no newer than @current" do
      Box::Release.latest.stub :newer? => false
      get 'index'
      assigns[:latest].should be_nil
    end

  end

  describe "GET 'download'" do

    before(:each) do
      controller.stub :resource => release
    end
    
    it "should start download of selected release" do
      release.should_receive(:start_download)
      get 'download', :id => "latest"
    end

    it "should redirect to releases_path" do
      release.stub :start_download
      get 'download', :id => "latest"
      response.should redirect_to(releases_path)
    end

  end

  describe "GET 'install'" do

    before(:each) do
      controller.stub :resource => release
    end
    
    it "should install selected release" do
      release.should_receive(:install)
      get 'install', :id => "latest"
    end

    it "should redirect to releases_path" do
      get 'install', :id => "latest"
      response.should redirect_to(releases_path)
    end

  end

  describe "GET 'show' in json (used by javascript ReleaseDownloadObserver)" do

    it "should use Box::Release.latest when given id is 'latest'" do
      Box::Release.stub :latest => release
      get 'show', :id => "latest", :format => "json"
      assigns[:release].should == release
    end

    it "should use Box::Release.current when given id is 'current'" do
      Box::Release.stub :current => release
      get 'show', :id => "current", :format => "json"
      assigns[:release].should == release
    end

  end

end
