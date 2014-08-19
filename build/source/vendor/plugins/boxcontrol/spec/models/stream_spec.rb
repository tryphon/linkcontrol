require 'spec_helper'

require File.expand_path("../../support/i18n", __FILE__)

describe Stream do

  subject { Stream.new }

  before(:each) do

    @puppet_configuration = PuppetConfiguration.new
    PuppetConfiguration.stub!(:load).and_return(@puppet_configuration)
  end

  after(:each) do
    PuppetConfiguration.destroy
  end

  it { should validate_presence_of :name }

  context "when server_type supports it" do

    before(:each) do
      subject.server_type.stub(:supports? => true)
    end

    it { should validate_presence_of :server, :port, :password, :mount_point }

  end

  context "when server_type doesn't support" do

    before(:each) do
      subject.server_type.stub(:supports? => false)
    end

    it { should_not validate_presence_of :server, :port, :password, :mount_point }

  end

  it "should remove initial / in mount point" do
    subject.mount_point = "/dummy"
    subject.mount_point.should == "dummy"
  end

  it "should validate server as a host" do
    subject.server = "localhost"
    subject.stub!(:validate_host).and_return(false)
    subject.should have(1).error_on(:server)
  end

  it "should strip attributes before validation" do
    subject.password = " dummy "
    subject.valid?
    subject.password.should == "dummy"
  end

  it "should use Stream.default_attributes for a new Stream" do
    Stream.stub :default_attributes => { :server => "dummy" }
    Stream.new.server.should == "dummy"
  end

  describe "for a new Stream" do

    subject { Stream.new }

    its(:format) { should == :vorbis }
    its(:quality) { should == 4 }
    its(:mode) { should == :vbr }
    it { should be_enabled }
    its(:server_type) { should be_icecast2 }
    
  end


  describe "server_type" do

    it { should validate_presence_of :server_type }
    
    it "should support :icecast2, :shoutcast and :local" do
      subject.should allow_values_for :server_type, :icecast2, :shoutcast, :local
      subject.should_not allow_values_for :server_type, :dummy
    end

    it "should find ServerType with given name" do
      Stream::ServerType.all.each do |type|
        subject.server_type = type.id
        subject.server_type.should == type
      end
    end

  end

  describe "format" do

    it { should validate_presence_of :format }
    
    it "should support :vorbis, :mp3 and :aac" do
      subject.should allow_values_for :format, :vorbis, :mp3, :aac, :aacp
      subject.should_not allow_values_for :format, :dummy
    end

    it "should transform the given format into a symbol" do
      subject.format = "vorbis"
      subject.format.should == :vorbis
    end

  end

  describe "#requires_quality? " do

    def allow_vbr
      simple_matcher("allows vbr") do |stream|
        stream.allows_vbr?
      end
    end

    # For rspec 2
    # RSpec::Matchers.define :require_quality do
    #   match do |stream|
    #     stream.require_quality?
    #   end
    # end
    
    it "should be false when format is aacp" do
      subject.format = :aacp
      subject.should_not allow_vbr
    end

  end

  describe "quality" do

    context "when the format allows quality" do
      before(:each) do
        subject.format = :vorbis
      end

      it { should validate_presence_of :quality }

      it "should accept quality between 0 and 10" do
        subject.should allow_values_for :quality, *(0..10).to_a
        subject.should_not allow_values_for :quality, -1, 11
      end

      it "should transforme the given quality into an integer" do
        subject.quality = "5"
        subject.quality.should == 5
      end
    end

    context "when the format doesn't allow quality" do

      before(:each) do
        subject.format = :aacp
      end

      it { should_not validate_presence_of :quality }

    end

  end

  describe "bitrate" do

    context "when the format allows cbr" do
      before(:each) do
        subject.stub :allows_cbr? => true
        subject.mode = :cbr
      end

      it { should validate_presence_of :bitrate }

      it "should accept bitrate in #allowed_birates" do
        subject.stub :allowed_bitrates => [42]
        subject.should allow_values_for :bitrate, 42
        subject.should_not allow_values_for :bitrate, 128
      end

      it "should transforme the given bitrate into an integer" do
        subject.bitrate = "32"
        subject.bitrate.should == 32
      end
    end

    context "when the format doesn't allow cbr" do

      before(:each) do
        subject.stub :allows_cbr? => false
      end

      it { should_not validate_presence_of :bitrate }

    end

  end

  describe "can_create? " do
    
    it "should be true when Stream count less than Stream.maximum_count" do
      Stream.stub!(:maximum_count).and_return(4)
      Stream.stub!(:count).and_return(3)
      Stream.can_create?.should be_true
    end

    it "should be false when Stream count equals Stream.maximum_count" do
      Stream.stub!(:maximum_count).and_return(3)
      Stream.stub!(:count).and_return(3)
      Stream.can_create?.should be_false
    end

  end

  describe "url" do
    
    it "should create a pseudo url with server, port and path" do
      subject.stub!(:server).and_return("server")
      subject.stub!(:port).and_return("port")
      subject.stub!(:mount_point).and_return("mount_point")

      subject.url.should == "server:port/mount_point"
    end

  end

  describe "path" do
    
    it "should return /mount_point if it doesn't include a starting /" do
      subject.mount_point = "mount_point"
      subject.path.should == "/mount_point"
    end

    it "should return mount_point if it includes a starting /" do
      subject.mount_point = "/mount_point"
      subject.path.should == "/mount_point"
    end

  end

  describe "default_attributes" do
    
    describe "port" do

      subject { Stream.default_attributes[:port] }

      it "should be 8000 if no other stream exists" do
        Stream.stub! :last
        should == 8000
      end

      it "should use the last stream port" do
        Stream.stub :last => Stream.new(:port => 80)
        should == 80
      end
      
    end

    def self.it_should_use_last_stream(attribute)
      describe attribute.to_s do

        subject { Stream.default_attributes[attribute] }
        
        it "should be nil if no other stream exists" do
          Stream.stub!(:last)
          should be_nil
        end

        it "should use the last stream #{attribute}" do
          Stream.stub :last => Stream.new(attribute => "dummy")
          should == "dummy"
        end

      end
    end

    it_should_use_last_stream :server
    it_should_use_last_stream :description
    it_should_use_last_stream :genre
    it_should_use_last_stream :related_url

  end

  describe "to_param" do
    
    it "should return stream id as string" do
      subject.id = 1
      subject.to_param.should == "1"
    end
    
  end

  describe "presenter" do

    it "should return a StreamPresenter" do
      StreamPresenter.should_receive(:new).with(subject).and_return(presenter = mock(StreamPresenter))
      subject.presenter.should == presenter
    end
    
  end

  describe "save" do
    
    it "should assign an identifier to new record" do
      subject.stub!(:valid?).and_return(true)
      subject.save
      subject.id.should_not be_nil
    end

    it "should modify stream_<id> configuration" do
      @puppet_configuration["stream_1_name"] = "old name"
      subject = Stream.find(1)
      subject.stub!(:valid?).and_return(true)
      subject.name = "new name"
      subject.save
      @puppet_configuration["stream_1_name"].should == "new name"
    end

    describe "when stream is invalid" do

      before(:each) do
        subject.stub!(:valid?).and_return(false)      
      end

      it "should return false" do
        subject.save.should be_false
      end

      it "should not modify PuppetConfiguration" do
        subject.save.should be_false
        @puppet_configuration.should be_empty
      end

      it "should return true if save is force" do
        subject.save(true).should be_true
      end
      
    end
    
  end

  describe "update_attributes" do
    
    it "should save Stream" do
      subject.should_receive(:save)
      subject.update_attributes :name => "test"
    end

  end

  describe "destroy" do
    
    it "should modify stream_<id> configuration" do
      @puppet_configuration["stream_1_name"] = "old name"
      Stream.find(1).destroy
      @puppet_configuration["stream_1_name"].should be_nil
    end

    it "should reorder other streams" do
      @puppet_configuration["stream_1_name"] = "removed"
      @puppet_configuration["stream_2_name"] = "kept"
      Stream.find(1).destroy
      @puppet_configuration["stream_1_name"].should == "kept"
      @puppet_configuration["stream_2_name"].should be_nil
    end

  end

  describe "class method" do

    describe "all" do
     
      it "should load 4 available streams" do
        5.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n}"
        end
        Stream.all.count.should == 4
      end

      it "should load attributes defined by stream_<n>_<attribute> keys" do
        4.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n}"
        end
        Stream.all.collect(&:name).should == Array.new(4) { |n| "Stream #{n}" }
      end

      it "should assign stream identifiers" do
        4.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n}"
        end
        Stream.all.collect(&:id).should == (1..4).to_a
      end

      it "should load enabled attribute defined by stream_<n>_enabled keys" do
        4.times do |n|
          @puppet_configuration["stream_#{n+1}_enabled"] = n.odd?
        end
        Stream.all.collect(&:enabled).should == [ false, true, false, true ]
      end

    end

    describe "find" do

      it "should return the Stream with the given identifier" do
        3.times do |n|
          @puppet_configuration["stream_#{n+1}_name"] = "Stream #{n+1}"
        end
        Stream.find(2).name.should == "Stream 2"
      end

      it "should support identifier as string" do
        @puppet_configuration["stream_1_name"] = "Stream 1"
        Stream.find("1").should_not be_nil
      end

      it "should return nil if id isn't found'" do
        Stream.find(1).should be_nil
      end
      
    end

    describe "count" do
      
      it "should return the size of Stream.all" do
        Stream.stub!(:all).and_return([1,2])
        Stream.count.should == 2
      end

    end

  end

  describe "enabled=" do
    
    it "should enable stream with 1" do
      subject.enabled=1
      subject.should be_enabled
    end

    it "should enable stream with true" do
      subject.enabled=true
      subject.should be_enabled
    end

    it "should enable stream with 'true'" do
      subject.enabled='true'
      subject.should be_enabled
    end

    it "should enable stream with '1'" do
      subject.enabled='1'
      subject.should be_enabled
    end

    it "should disable stream with anything else" do
      subject.enabled = mock
      subject.should be_disabled
    end

  end

  describe "metadata_updater" do

    subject { stream.metadata_updater }
    
    context "for icecast stream" do

      let(:stream) { Stream.new :server_type => :icecast2, :server => "server", :port => 9000, :password => "secret", :mount_point => "test.ogg" }

      its(:server) { should == stream.server }
      its(:port) { should == stream.port }
      its(:password) { should == stream.password }
      its(:mount) { should == "/#{stream.mount_point}" }

      it { should be_instance_of(Metalive::Icecast) }

    end

    context "for shoutcast stream" do

      let(:stream) { Stream.new :server_type => :shoutcast, :server => "server", :port => 9000, :password => "secret" }

      its(:server) { should == stream.server }
      its(:password) { should == stream.password }

      it "should use the admin port (stream port - 1)" do
        subject.port.should == stream.port - 1
      end

      it { should be_instance_of(Metalive::Shoutcast) }

    end

  end

end

describe Stream::ServerType do

  subject { Stream::ServerType.new :test }

  describe "#supports?" do
    
    it "should be false when given attribute is in disabled attributes" do
      subject.disabled_attributes = [:dummy]
      subject.supports?(:dummy).should be_false
    end

    it "should be true when given attribute isn't in disabled attributes" do
      subject.disabled_attributes = [:other]
      subject.supports?(:dummy).should be_true
    end

  end

  def support(*attributes)
    simple_matcher("support #{attributes.to_sentence}") do |actual|
      attributes.all? do |attribute|
        actual.supports? attribute
      end
    end
  end


  describe "icecast2" do
    
    subject { Stream::ServerType.icecast2 }

    it "should have 'Icecast2' as name" do
      subject.name.should == 'Icecast2'
    end

    it { should support(:password) }

  end

  describe "shoutcast" do
    
    subject { Stream::ServerType.shoutcast }

    its(:name) { should == 'Shoutcast DNAS' }

    it { should_not support(:mount_point) }

  end

  describe "local" do
    
    subject { Stream::ServerType.local }

    it "should have 'Local Stream' name" do
      I18n.with_locale(:en) do
        subject.name.should == 'Local Streaming'
      end
    end

    it { should_not support(:server, :port, :password) }

  end

  describe "tryphon" do
    
    subject { Stream::ServerType.tryphon }

    it "should have 'Tryphon Stream' name" do
      I18n.with_locale(:en) do
        subject.name.should == 'Tryphon Stream'
      end
    end

    it { should_not support(:server, :port, :password) }

  end

end
