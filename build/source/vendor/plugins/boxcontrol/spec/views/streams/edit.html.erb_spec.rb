require 'spec_helper'

describe "/streams/edit" do

  let(:stream_path) { '/streams/:id' }

  before(:each) do
    # Stream routes aren't always defined in parent Rails app
    template.stub :stream_path => stream_path

    assigns[:stream] = @stream = Stream.new(:id => 1)
  end

  it "should provide a back link to the stream path" do
    render
    response.should have_tag("a[href=?]", stream_path(@stream))
  end

end
