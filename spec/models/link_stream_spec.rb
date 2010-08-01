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

  it "should support a undefined http port" do
    @link_stream.http_port = nil
    @link_stream.should be_valid
    @link_stream.http_port.should be_nil
  end

  describe "http_enabled?" do

    context "when http port is defined" do
      before(:each) do
        subject.http_port = 8000
      end
      it { should be_http_enabled }
    end

    context "when http port is not defined" do
      before(:each) do
        subject.http_port = nil
      end
      it { should_not be_http_enabled }
    end

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

  it { pending "remarkable matcher doesn't support default value"; should validate_numericality_of(:target_port, :udp_port,:http_port, :only_integer => true, :greater_than => 1024, :less_than => 65536) }

  it "should validate that target_host is a valid hostname" do
    @link_stream.should allow_values_for(:target_host, "localhost", "192.168.0.1")
    Socket.should_receive(:gethostbyname).and_raise("No such host")
    @link_stream.should_not allow_values_for(:target_host, "dummy", "192.168.0")
  end

  describe "packetizer" do
    # :interleaving => 2, :repeat => 2, :packet_size => 1200
    
    describe "interleaving" do
      it "should accept values from 1 to 10" do
        @link_stream.should allow_values_for(:packetizer_interleaving, 1..10)
        @link_stream.should_not allow_values_for(:packetizer_interleaving, 0)
      end

      it { should_not validate_presence_of(:packetizer_interleaving) }
    end

    describe "repeat" do
      it "should accept values from 1 to 10" do
        @link_stream.should allow_values_for(:packetizer_repeat, 1..10)
        @link_stream.should_not allow_values_for(:packetizer_repeat, 0)
      end

      it { should_not validate_presence_of(:packetizer_repeat) }
    end

    describe "packet_size" do
      it "should accept values from 100 to 10k" do
        @link_stream.should allow_values_for(:packetizer_packet_size, 100, 10.kilobytes)
        @link_stream.should_not allow_values_for(:packetizer_packet_size, 1.megabyte)
      end

      it { should_not validate_presence_of(:packetizer_packet_size) }
    end

    describe "with_packetizer_properties?" do

      context "when packetizer_interleaving, packetizer_repeat and packetizer_packet_size are blank" do
        before(:each) do
          [:packetizer_interleaving, :packetizer_repeat, :packetizer_packet_size].each do |attribute|
            subject[attribute] = ""
          end
        end

        it { should_not be_with_packetizer_properties }
      end
      
      context "when one of packetizer_interleaving, packetizer_repeat and packetizer_packet_size isn't blank" do
        before(:each) do
          subject[:packetizer_interleaving] = 2  
        end
        
        it { should be_with_packetizer_properties }
      end
    end
  end

  describe "unpacketizer" do

    describe "time_to_live" do
      it "should accept values from 1 to 50" do
        @link_stream.should allow_values_for(:unpacketizer_time_to_live, 1..50)
        @link_stream.should_not allow_values_for(:unpacketizer_time_to_live, 0, 100)
      end

      it { should_not validate_presence_of(:unpacketizer_time_to_live) }
    end

  end

  describe "alsa_capture" do
    
    it "should accept 'true' as boolean true" do
      @link_stream.alsa_capture = "true"
      @link_stream.should be_alsa_capture
    end

    it "should accept '1' as boolean true" do
      @link_stream.alsa_capture = "1"
      @link_stream.should be_alsa_capture
    end

  end

  describe "alsa_playback" do
    
    it "should accept 'true' as boolean true" do
      @link_stream.alsa_playback = "true"
      @link_stream.should be_alsa_playback
    end

    it "should accept '1' as boolean true" do
      @link_stream.alsa_playback = "1"
      @link_stream.should be_alsa_playback
    end

  end

  describe "save" do
    
    before(:each) do
      @puppet_configuration = PuppetConfiguration.new
      PuppetConfiguration.stub!(:load).and_return(@puppet_configuration)
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

  it "should not be a new record" do
    @link_stream.should_not be_new_record
  end

end
