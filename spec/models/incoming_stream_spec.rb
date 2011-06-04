require 'spec_helper'

describe IncomingStream do

  its(:puppet_configuration_prefix) { should == "link_incoming" }

  describe "save" do

    let(:puppet_configuration) { PuppetConfiguration.new }
    
    before(:each) do
      PuppetConfiguration.stub!(:load).and_return(puppet_configuration)
    end

    def self.it_should_configure(attribute, options = {})
      configuration_key = (options[:as] or attribute.to_s)
      value = options[:value]

      it "should configure #{attribute} as #{configuration_key}" do
        subject.send("#{attribute}=", value)
        subject.save
        puppet_configuration[configuration_key].should == value
      end
    end

    it_should_configure :host, :as => "link_incoming_host", :value => "localhost"
    it_should_configure :port, :as => "link_incoming_port", :value => 8000
    it_should_configure :password, :as => "link_incoming_password", :value => "secret"

  end

  describe "load" do

    let(:puppet_configuration) { PuppetConfiguration.new }
    
    before(:each) do
      PuppetConfiguration.stub!(:load).and_return(puppet_configuration)
    end

    def self.it_should_use(configuration_key, options = {})
      attribute = (options[:as] or configuration_key)
      value = options[:value]

      it "should use #{configuration_key} as #{attribute} attribute" do
        puppet_configuration[configuration_key] = value
        subject.load
        subject.send(attribute).should == value
      end
    end

    it_should_use :link_incoming_host, :as => :host, :value => "localhost"
    it_should_use :link_incoming_port, :as => :port, :value => 8000
    it_should_use :link_incoming_password, :as => :password, :value => "secret"

  end

end
