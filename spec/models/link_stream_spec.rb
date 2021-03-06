# coding: utf-8
require 'spec_helper'

describe LinkStream do

  describe "by default" do
    it "should use 8000 as port" do
      subject.port.should == 8000
    end
  end

  it "should use default port when port is not specified" do
    subject.port = nil
    subject.valid?
    subject.port.should == subject.default_port
  end

  it { pending "remarkable matcher doesn't support default value"; should validate_numericality_of(:port, :only_integer => true, :greater_than => 1024, :less_than => 65536) }

  it "should validate that host is a valid hostname" do
    subject.should allow_value("localhost", "192.168.0.1").for(:host)

    Socket.stub(:gethostbyname).and_raise("No such host")
    subject.should_not allow_value("dummy", "192.168.0").for(:host)
  end

  describe "#password" do

    it { should allow_value("Yoofu8Oh", "meeG5eem").for(:password) }
    it { should_not allow_value("Yoofu 8Oh", "meeG/5eem").for(:password) }

    it "should not accept less than 6 character" do
      subject.should_not allow_value("a", "aaa", "aaaaa").for(:password)
    end

    it "should be optionnal in pull mode" do
      subject.mode = "pull"
      subject.should allow_value(nil, "").for(:password)
    end

    it "should be mandatory in push mode" do
      subject.mode = "push"
      subject.should validate_presence_of(:password)
    end

  end

  it "should not be a new record" do
    subject.should be_persisted
  end

  it { should ensure_inclusion_of(:mode).in_array(%w{push pull}) }

  describe "#push?" do

    it "should be true when mode is push" do
      subject.mode = "push"
      subject.should be_push
    end

    it "should be false when mode is pull" do
      subject.mode = "pull"
      subject.should_not be_push
    end

  end

  describe "#local_ip" do

    it "should return address associated to the eth0 Network interface" do
      Network.should_receive(:find).with("eth0").and_return(mock :address => "172.20.2.10")
      subject.local_ip.should == "172.20.2.10"
    end

  end

  describe "#public_ip" do

    it "should return the public ip returned by http://www.freecast.org/reference.php" do
      subject.should_receive(:open).with("http://www.freecast.org/reference.php").and_return("1.2.3.4")
      subject.public_ip.should == "1.2.3.4"
    end

    it "should return nil on timeout" do
      subject.should_receive(:open).with("http://www.freecast.org/reference.php").and_raise(Timeout::Error)
      subject.public_ip.should be_nil
    end

  end

end
