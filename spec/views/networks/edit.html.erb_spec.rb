require 'spec_helper'

describe "/networks/edit" do
  before(:each) do
    render 'networks/edit'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/networks/edit])
  end
end
