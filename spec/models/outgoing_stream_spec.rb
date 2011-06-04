require 'spec_helper'

describe OutgoingStream do

  subject { OutgoingStream.new :host => "localhost", :port => 8000 }

  its(:puppet_configuration_prefix) { should == "link_outgoing" }

  describe "#quality" do

    it { should allow_values_for(:quality, *(0..10).to_a) }
    it { should_not allow_values_for(:quality, -1, 11) }
    it { should validate_presence_of(:quality) }

  end

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

    it_should_configure :host, :as => "link_outgoing_host", :value => "localhost"
    it_should_configure :port, :as => "link_outgoing_port", :value => 8000
    it_should_configure :password, :as => "link_outgoing_password", :value => "secret"
    it_should_configure :quality, :as => "link_outgoing_quality", :value => 5

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

    it_should_use :link_outgoing_host, :as => :host, :value => "localhost"
    it_should_use :link_outgoing_port, :as => :port, :value => 8000
    it_should_use :link_outgoing_password, :as => :password, :value => "secret"
    it_should_use :link_outgoing_quality, :as => :quality, :value => 5

  end

  context "in push mode" do

    before(:each) do
      subject.mode = "push"
    end

    it { should validate_presence_of(:host) }
                           
  end

end
