require 'spec_helper'

describe "/releases/index" do
  before(:each) do
    assigns[:current] = @current = Box::Release.current
    assigns[:latest] = @latest = Box::Release.latest
  end

  it "should display current human name" do
    render 'releases/index'
    response.should have_tag("p", /#{@current.human_name}/)
  end

  it "should display latest human name" do
    render 'releases/index'
    response.should have_tag("p", /#{@latest.human_name}/)
  end

end
