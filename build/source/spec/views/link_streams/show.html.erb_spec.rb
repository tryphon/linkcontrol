require 'spec_helper'

describe "/link_streams/show" do
  before(:each) do
    assigns[:link_stream] = @link_stream = LinkStream.new
    render 'link_streams/show'
  end

end
