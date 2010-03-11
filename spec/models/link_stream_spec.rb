require 'spec_helper'

describe LinkStream do

  before(:each) do
    @link_stream = LinkStream.new
  end

  describe "by default" do

    def self.it_should_use(value, options)
      attribute = options[:as] 
      it "should use #{value} as #{attribute}" do
        @link_stream.send(attribute).should == value
      end
    end

    it_should_use "localhost", :as => :target_host
    it_should_use 14100, :as => :target_port
    it_should_use 14100, :as => :udp_port
    it_should_use 8000, :as => :http_port
  end

  it "should accept a blank target_host" do
    @link_stream.should allow_values_for(:target_host, "")
  end

  it "should accept a blank target_port" do
    @link_stream.should allow_values_for(:target_port, "")
  end

  def self.it_should_use_default_port_for(attribute, type)
    it "should use default port when #{attribute} is not specified" do
      @link_stream.send("#{attribute}=", nil)
      @link_stream.valid?
      @link_stream.send(attribute).should == @link_stream.send("default_#{type}_port")
    end
  end

  it_should_use_default_port_for :target_port, :udp
  it_should_use_default_port_for :udp_port, :udp
  it_should_use_default_port_for :http_port, :http

  it { pending "remarkable matcher doesn't support default value"; should validate_numericality_of(:target_port, :udp_port,:http_port, :only_integer => true, :greater_than => 1024, :less_than => 65536) }

  it "should validate that target_host is a valid hostname" do
    @link_stream.should allow_values_for(:target_host, "localhost", "192.168.0.1")
    @link_stream.should_not allow_values_for(:target_host, "dummy", "192.168.0")
  end

  describe "save" do
    
    before(:each) do
      @puppet_configuration = PuppetConfiguration.new
      PuppetConfiguration.stub!(:load).and_return(@puppet_configuration)
    end

    it "should return false if the network isn't valid" do
      @link_stream.stub!(:valid?).and_return(false)
      @link_stream.save.should be_false
    end

    it "should not modifiy puppet configuration if not valid" do
      @link_stream.stub!(:valid?).and_return(false)
      @link_stream.save
      @puppet_configuration.should be_empty
    end

    it "should return true if the configuration is saved" do
      @link_stream.save.should be_true
    end

    it "should return false if the configuration can't be saved" do
      @puppet_configuration.stub!(:save).and_return(false)
      @link_stream.save.should be_false
    end

    def self.it_should_configure(attribute, options = {})
      configuration_key = (options[:as] or attribute.to_s)
      value = options[:value]

      it "should configure #{attribute} as #{configuration_key}" do
        @link_stream.send("#{attribute}=", value)
        @link_stream.save
        @puppet_configuration[configuration_key].should == value
      end
    end

    it_should_configure :target_host, :as => "linkstream_target_host", :value => "localhost"
    it_should_configure :target_port, :as => "linkstream_target_port", :value => 14100
    it_should_configure :udp_port, :as => "linkstream_udp_port", :value => 14100
    it_should_configure :http_port, :as => "linkstream_http_port", :value => 8000

  end

  describe "load" do
    
    before(:each) do
      @puppet_configuration = PuppetConfiguration.new
      PuppetConfiguration.stub!(:load).and_return(@puppet_configuration)
    end

    def self.it_should_use(configuration_key, options = {})
      attribute = (options[:as] or configuration_key)
      value = options[:value]

      it "should use #{configuration_key} as #{attribute} attribute" do
        @puppet_configuration[configuration_key] = value
        @link_stream.load
        @link_stream.send(attribute).should == value
      end
    end

    it_should_use :linkstream_target_host, :as => :target_host, :value => "localhost"
    it_should_use :linkstream_target_port, :as => :target_port, :value => 14100
    it_should_use :linkstream_udp_port, :as => :udp_port, :value => 14100
    it_should_use :linkstream_http_port, :as => :http_port, :value => 8000
  end

  describe "class method load" do
    
    it "should create a new LinkStream instance and load it" do
      LinkStream.should_receive(:new).and_return(@link_stream)
      @link_stream.should_receive(:load)
      LinkStream.load.should == @link_stream
    end

  end

  it "should not be a new record" do
    @link_stream.should_not be_new_record
  end

end
