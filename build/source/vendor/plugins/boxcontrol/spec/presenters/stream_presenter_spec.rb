require 'spec_helper'

describe StreamPresenter do

  let(:stream) { mock(Stream) }
  subject { StreamPresenter.new(stream) }

  describe "format" do
    
    it "should find the associated StreamFormatPresenter" do
      stream.stub!(:format).and_return("dummy")
      StreamFormatPresenter.should_receive(:find).with("dummy").and_return(format_presenter = mock(StreamFormatPresenter))
      subject.format.should == format_presenter
    end

  end

  describe "blank_description_attributes?" do

    it "should be true when Stream description, genre and related_url are blank" do
      stream.stub :description => "", :genre => "", :related_url => ""
      subject.should be_blank_description_attributes
    end

  end


end
