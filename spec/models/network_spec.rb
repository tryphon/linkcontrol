require 'spec_helper'

describe Network do

  def delete_configuration_file
    File.delete(Network.configuration_file) if File.exists?(Network.configuration_file)
  end

  before(:each) do
    @network = Network.new
  end

  it "should use tmp/config.pp as default configuration file" do
    Network.configuration_file.should == "tmp/config.pp"
  end

  it "should not have a system update command by default" do
    Network.system_update_command.should be_nil
  end
  
  describe "save" do
    
    before(:each) do
      delete_configuration_file
    end

    def configuration
      File.readlines(Network.configuration_file).collect(&:strip)
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
