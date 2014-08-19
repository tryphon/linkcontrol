require 'spec_helper'

describe "/streams/new" do

  let(:streams_path) { '/streams' }

  before(:each) do
    # Stream routes aren't always defined in parent Rails app
    template.stub :streams_path => streams_path
    assigns[:stream] = @stream = Stream.new
  end

  it "should provide a back link to the streams path" do
    render
    response.should have_tag("a[href=?]", streams_path)
  end

end
