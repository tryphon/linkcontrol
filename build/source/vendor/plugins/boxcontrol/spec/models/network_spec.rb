# -*- coding: utf-8 -*-
require 'spec_helper'

describe Network do

  subject { Network.new :id => "eth0" }

  def delete_configuration_file
    File.delete(PuppetConfiguration.configuration_file) if File.exists?(PuppetConfiguration.configuration_file)
  end

  after(:each) do
    delete_configuration_file
  end

  describe "by default" do

    def self.it_should_use(value, options)
      attribute = options[:as] 
      it "should use #{value} as #{attribute}" do
        subject.send(attribute).should == value
      end
    end

    it_should_use "dhcp", :as => :method
    it_should_use "192.168.1.100", :as => :static_address
    it_should_use "255.255.255.0", :as => :static_netmask
    it_should_use "192.168.1.1", :as => :static_gateway
    it_should_use "192.168.1.1", :as => :static_dns1
  end

  it { should validate_inclusion_of :method, :in => %w{dhcp static} }

  describe "when method is static" do

    before(:each) do
      subject.method = "static"
      subject.static_netmask = "0.0.0.0"
    end

    it "should validate presence of static attributes" do
      subject.should validate_presence_of(:static_address, :static_netmask, :static_gateway, :static_dns1)
    end

    def self.it_should_validate_ip_address(attribute)
      it "should validate that #{attribute} is a valid ip address" do
        subject.should allow_values_for(attribute, "192.168.0.1", "172.10.10.1", "10.0.0.254")
        subject.should_not allow_values_for(attribute, "192.168.0", "192.168.0.256", "abc")
      end
    end

    it_should_validate_ip_address :static_address
    it_should_validate_ip_address :static_dns1

    it "should validate that static dns1 is not the static address" do
      subject.should allow_values_for(:static_dns1, subject.static_address)
    end

    describe "default gateway" do

      before(:each) do
        subject.static_address = "192.168.0.10"
        subject.static_netmask = "255.255.255.0"
      end

      it "should be a valid ip address" do
        subject.should allow_values_for(:static_gateway, "192.168.0.1")
        subject.should_not allow_values_for(:static_gateway, "192.168.0", "192.168.0.256", "abc")
      end

      it "should be in local network" do
        subject.should_not allow_values_for(:static_gateway, "172.10.0.1")
      end

      it "should be the static ip address" do
        subject.should_not allow_values_for(:static_gateway, subject.static_address)
      end
      
    end

    
  end

  describe "when method is dhcp" do

    before(:each) do
      subject.method = "dhcp"
    end

    it "should not validate presence of static attributes" do
      subject.should_not validate_presence_of(:static_address, :static_netmask, :static_gateway, :static_dns1) 
    end

  end
  
  describe "save" do

    let(:puppet_configuration) { PuppetConfiguration.new }
    
    before(:each) do
      PuppetConfiguration.stub!(:load).and_return(puppet_configuration)
    end

    it "should save attributes in 'network_interfaces'" do
      subject.save
      puppet_configuration['network_interfaces'].should =~ [ subject.attributes ]
    end

  end

  describe ".saved_configurations" do
    
    let(:puppet_configuration) { PuppetConfiguration.new }

    before(:each) do
      PuppetConfiguration.stub!(:load).and_return(puppet_configuration)
    end

    it "should use Array stored in network_interfaces" do
      Network.stub :interface_ids => %w{eth0 eth1}
      puppet_configuration["network_interfaces"] = [{"id" => "eth0", "key1" => "value1"}, {"id" => "eth1", "key2" => "value2"}]
      Network.saved_configurations.should == { "eth0" => {"id" => "eth0", "key1" => "value1"}, "eth1" => {"id" => "eth1", "key2" => "value2"} }
    end

    it "should ignore interfaces not present in Network#interface_ids" do
      Network.stub :interface_ids => %w{eth0}
      puppet_configuration["network_interfaces"] = [{"id" => "eth0", "key1" => "value1"}, {"id" => "eth1", "key2" => "value2"}]
      Network.saved_configurations.should == { "eth0" => {"id" => "eth0", "key1" => "value1"} }
    end

  end

  it "should not be a new record" do
    subject.should_not be_new_record
  end

  describe ".interface_ids" do
    
    it "should be 'eth0' by default" do
      Network.interface_ids.should == ["eth0"]
    end

  end

  describe ".all" do
    
    it "should return a Network for each interface" do
      Network.stub :interface_ids => %w{eth0 eth1 wlan0}
      Network.all.map(&:id).should =~ Network.interface_ids
    end
                
  end

  describe "find" do
    
    it "should return the Network with specified id" do
      Network.find("eth0").id.should == "eth0"
    end

    it "should return nil if the Network doesn't exist" do
      Network.find("dummy").should be_nil
    end

  end

  describe ".blank_configurations" do
    
    it "should return attributes map for each interface_ids" do
      Network.blank_configurations.keys.should =~ Network.interface_ids
    end

    it "should return an empty Network foe each interface_id" do
      Network.stub :interface_ids => %w{eth0}
      Network.blank_configurations["eth0"].should == { "id" => "eth0" }
    end

  end

  describe ".configurations" do

    it "should merge saved_configurations and blank_configurations" do
      Network.stub :blank_configurations => { "eth0" => { "id" => "eth0" }, "eth1" => { "id" => "eth1" }}
      Network.stub :saved_configurations => { "eth0" => { "id" => "eth0", "key" => "value" }}

      Network.configurations.should == { "eth0" => { "id" => "eth0", "key" => "value" }, "eth1" => { "id" => "eth1" }}
    end

  end

end
