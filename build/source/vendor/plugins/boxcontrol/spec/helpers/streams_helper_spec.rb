require 'spec_helper'

describe StreamsHelper do

  describe "format_radio_buttons" do

    before(:each) do
      @format_presenter = mock StreamFormatPresenter, :format => "dummy", :name => "Dummy", :wikipedia_url => "http://wikipedia/Dummy", :allows_cbr? => false, :allows_vbr? => true
      StreamFormatPresenter.stub!(:all).and_return([ @format_presenter ])
      
      @form_builder = mock(ActionView::Helpers::FormBuilder, :radio_button => '<input type="radio"/>', :label => '<label/>')
    end

    it "should return an ul tag" do
      helper.format_radio_buttons(@form_builder).should have_tag("ul")
    end

    it "should return an li tag for each Stream format" do
      StreamFormatPresenter.stub!(:all).and_return([ @format_presenter ] * 3)
      helper.format_radio_buttons(@form_builder).should have_tag("li", :count => 3)
    end

    it "should display a radio button to select format" do
      @form_builder.should_receive(:radio_button).with(:format, "dummy", {:"data-allows-cbr" => false, :"data-allows-vbr" => true}).and_return('<input type="radio"/>')
      helper.format_radio_buttons(@form_builder).should have_tag("input[type=radio]")
    end

    it "should display a label with format name" do
      @form_builder.should_receive(:label).with("format_dummy", "Dummy").and_return('<label/>')
      helper.format_radio_buttons(@form_builder).should have_tag("label")
    end

    it "should display a link_to wikipedia page" do
      helper.format_radio_buttons(@form_builder).should have_tag("a[href=?]", @format_presenter.wikipedia_url)
    end

  end

end
