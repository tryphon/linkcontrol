require 'spec_helper'

describe SavePoint do

  before(:each) do
    @save_point = SavePoint.new
  end

  it "should use Network configuration file as transient file" do
    @save_point.transient_file.should == Network.configuration_file
  end

  it "should use 'tmp/config_saved.pp' as default persistent file" do
    @save_point.persistent_file.should == 'tmp/config_saved.pp'
  end

  it "should return true if persistent file is successfully modified" do
    @save_point.save.should be_true
  end

  it "should return false if persistent file can be modified" do
    @save_point.stub!(:persistent_file).and_return("/dummy")
    @save_point.save.should be_false
  end

  it "should copy transient file in persistent one" do
    File.open(@save_point.transient_file, "w") { |f| f.write "dummy" }
    @save_point.save
    File.read(@save_point.persistent_file).should == "dummy"
  end

end
