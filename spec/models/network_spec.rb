# -*- coding: utf-8 -*-
require 'spec_helper'

describe Network do

  def delete_configuration_file
    File.delete(Network.configuration_file) if File.exists?(Network.configuration_file)
  end

  before(:each) do
    @network = Network.new
  end

  describe "by default" do

    def self.it_should_use(value, options)
      attribute = options[:as] 
      it "should use #{value} as #{attribute}" do
        @network.send(attribute).should == value
      end
    end

    it_should_use "dhcp", :as => :method
    it_should_use "192.168.1.100", :as => :static_address
    it_should_use "255.255.255.0", :as => :static_netmask
    it_should_use "192.168.1.1", :as => :static_gateway
    it_should_use "192.168.1.1", :as => :static_dns1

    it_should_use "localhost", :as => :linkstream_target_host
    it_should_use 14100, :as => :linkstream_target_port
    it_should_use 14100, :as => :linkstream_udp_port
    it_should_use 8000, :as => :linkstream_http_port
  end

  it "should use tmp/config.pp as default configuration file" do
    Network.configuration_file.should == "tmp/config.pp"
  end

  it "should not have a system update command by default" do
    Network.system_update_command.should be_nil
  end

  it { should validate_inclusion_of :method, :in => %w{dhcp static} }

  describe "when method is static" do

    before(:each) do
      @network.method = "static"
      @network.static_netmask = "0.0.0.0"
    end

    it "should validate presence of static attributes" do
      @network.should validate_presence_of(:static_address, :static_netmask, :static_gateway, :static_dns1) 
    end

    def self.it_should_validate_ip_address(attribute)
      it "should validate that #{attribute} is a valid ip address" do
        @network.should allow_values_for(attribute, "192.168.0.1", "172.10.10.1", "10.0.0.254")
        @network.should_not allow_values_for(attribute, "192.168.0", "192.168.0.256", "abc")
      end
    end

    it_should_validate_ip_address :static_address
    it_should_validate_ip_address :static_dns1

    it "should validate that static dns1 is not the static address" do
      @network.should allow_values_for(:static_dns1, @network.static_address)
    end

    describe "default gateway" do

      before(:each) do
        @network.static_address = "192.168.0.10"
        @network.static_netmask = "255.255.255.0"
      end

      it "should be a valid ip address" do
        @network.should allow_values_for(:static_gateway, "192.168.0.1")
        @network.should_not allow_values_for(:static_gateway, "192.168.0", "192.168.0.256", "abc")
      end

      it "should be in local network" do
        @network.should_not allow_values_for(:static_gateway, "172.10.0.1")
      end

      it "should be the static ip address" do
        @network.should_not allow_values_for(:static_gateway, @network.static_address)
      end
      
    end

    
  end

  describe "when method is dhcp" do

    before(:each) do
      @network.method = "dhcp"
    end

    it "should not validate presence of static attributes" do
      @network.should_not validate_presence_of(:static_address, :static_netmask, :static_gateway, :static_dns1) 
    end

  end

  it "should accept a blank linkstream_target_host" do
    @network.should allow_values_for(:linkstream_target_host, "")
  end

  it "should accept a blank linkstream_target_port" do
    @network.should allow_values_for(:linkstream_target_port, "")
  end

  def self.it_should_use_default_port_for(attribute, type)
    it "should use default port when #{attribute} is not specified" do
      @network.send("#{attribute}=", nil)
      @network.valid?
      @network.send(attribute).should == @network.send("default_#{type}_port")
    end
  end

  it_should_use_default_port_for :linkstream_target_port, :udp
  it_should_use_default_port_for :linkstream_udp_port, :udp
  it_should_use_default_port_for :linkstream_http_port, :http

  it { pending; should validate_numericality_of(:linkstream_target_port, :linkstream_udp_port,:linkstream_http_port, :only_integer => true, :greater_than => 1024, :less_than => 65536) }

  it "should validate that linkstream_target_host is a valid hostname" do
    @network.should allow_values_for(:linkstream_target_host, "localhost", "192.168.0.1")
    @network.should_not allow_values_for(:linkstream_target_host, "dummy", "192.168.0")
  end
  
  describe "save" do
    
    before(:each) do
      delete_configuration_file
    end

    def configuration
      File.readlines(Network.configuration_file).collect(&:strip)
    end

    it "should return false if the network isn't valid" do
      @network.stub!(:valid?).and_return(false)
      @network.save.should be_false
    end

    it "should not modifiy configuration fie if not valid" do
      @network.stub!(:valid?).and_return(false)
      @network.save
      File.exists?(@network.configuration_file).should be_false
    end

    it "should return true if the configuration is saved" do
      @network.save.should be_true
    end

    it "should return false if the configuration can't be saved" do
      @network.stub!(:configuration_file).and_return("/dummy")
      @network.save.should be_false
    end

    def self.it_should_configure(attribute, options = {})
      configuration_key = (options[:as] or attribute.to_s)
      value = options[:value]

      it "should configure #{attribute} as #{configuration_key}" do
        @network.send("#{attribute}=", value)
        @network.save
      
        configuration.should include("$#{configuration_key}=\"#{value}\"")
      end

      it "should configure #{configuration_key} even without value" do
        @network.send("#{attribute}=", "")
        @network.stub!(:valid?).and_return(true)
        @network.save
        configuration.should include("$#{configuration_key}=\"\"")
      end
    end

    it_should_configure :method, :as => "network_method", :value => "dhcp"
    it_should_configure :static_address, :as => "network_static_address", :value => "192.168.1.2"
    it_should_configure :static_netmask, :as => "network_static_netmask", :value => "255.255.255.0"
    it_should_configure :static_gateway, :as => "network_static_gateway", :value => "192.168.1.1"
    it_should_configure :static_dns1, :as => "network_static_dns1", :value => "192.168.1.1"

    it_should_configure :linkstream_target_host, :value => "localhost"
    it_should_configure :linkstream_target_port, :value => "14100"
    it_should_configure :linkstream_udp_port, :value => "14100"
    it_should_configure :linkstream_http_port, :value => "8000"

    it "should run the system_update_command if defined" do
      @network.stub!(:system_update_command).and_return("dummy")
      @network.should_receive(:system).with(@network.system_update_command).and_return(true)
      @network.save
    end

    it "should return false if the system_update_command isn't successfully executed" do
      @network.stub!(:system_update_command).and_return("dummy")
      @network.stub!(:systen).and_return(false)
      @network.save.should be_false
    end

  end

  describe "load" do
    
    def configuration_with(key, value)
      File.open(Network.configuration_file, "w") do |f|
        f.puts "$#{key}=\"#{value}\""
      end
    end

    after(:each) do
      delete_configuration_file
    end

    def self.it_should_use(configuration_key, options = {})
      attribute = (options[:as] or configuration_key)
      value = options[:value]

      it "should use #{configuration_key} as #{attribute} attribute" do
        configuration_with(configuration_key, value)
        @network.load
        @network.send(attribute).should == value
      end
    end

    it_should_use :network_method, :as => :method, :value => "dhcp"
    it_should_use :network_static_address, :as => :static_address, :value => "192.168.1.2"
    it_should_use :network_static_netmask, :as => :static_netmask, :value => "255.255.255.0"
    it_should_use :network_static_gateway, :as => :static_gateway, :value => "192.168.1.1"
    it_should_use :network_static_dns1, :as => :static_dns1, :value => "192.168.1.1"

    it_should_use :linkstream_target_host, :value => "localhost"
    it_should_use :linkstream_target_port, :value => 14100
    it_should_use :linkstream_udp_port, :value => 14100
    it_should_use :linkstream_http_port, :value => 8000

  end

  describe "class method load" do
    
    it "should create a new Network instance and load it" do
      Network.should_receive(:new).and_return(@network)
      @network.should_receive(:load)
      Network.load.should == @network
    end

  end

end
