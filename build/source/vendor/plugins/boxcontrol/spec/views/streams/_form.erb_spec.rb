require 'spec_helper'

describe "/streams/_form" do

  let(:streams_path) { '/streams' }

  before(:each) do
    # Stream routes aren't always defined in parent Rails app
    template.stub :streams_path => streams_path

    assigns[:stream] = @stream = Stream.new(:id => 1)

    @form_builder = stub :text_field => '<input type="text"/>', :label => '<label/>', :collection_select => "<select/>", :check_box => '<input type="checkbox"/>', :select => '<select/>'

    template.stub!(:format_radio_buttons)
    template.stub!(:mode_radio_buttons)
  end

  def render_view
    render :partial => "/streams/form", :locals => { :form => @form_builder }
  end

  it "should the helper format_radio_buttons" do
    template.should_receive(:format_radio_buttons).with(@form_builder)
    render_view
  end

  it "should display a select to choose a quality between 0 and 10" do
    @form_builder.should_receive(:collection_select).with(:quality, 0..10, :to_i, :to_s)
    render_view
  end

end
