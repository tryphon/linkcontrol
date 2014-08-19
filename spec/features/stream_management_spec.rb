# require "rails_helper"

feature "Scenario management" do
  scenario "User defines pull outgoing stream" do
    visit "/outgoing_stream/edit"

    choose "outgoing_stream_mode_pull" # Available locally (pull mode)
    fill_in "Password", :with => "alongsecret"
    select "7", from: "Quality"

    click_button "Save"

    expect(current_url).to eq(outgoing_stream_url)

    expect(page).to have_text("Transport mode : Available locally (pull mode)")
    expect(page).to have_text("Password : alongsecret")
    expect(page).to have_text("Quality : 7")
  end

  scenario "User defines push outgoing stream" do
    visit "/outgoing_stream/edit"

    choose "outgoing_stream_mode_push" # Sent to (push mode)
    fill_in "outgoing_stream_host", with: "localhost"
    fill_in "outgoing_stream_port", with: "9000"

    fill_in "Password", :with => "alongsecret"
    select "7", from: "Quality"

    click_button "Save"

    expect(current_url).to eq(outgoing_stream_url)

    expect(page).to have_text("Transport mode : Sent to (push mode)")
    expect(page).to have_text("Destination : localhost:9000")
    expect(page).to have_text("Password : alongsecret")
    expect(page).to have_text("Quality : 7")
  end

  scenario "User defines push incoming stream" do
    visit "/incoming_stream/edit"

    choose "incoming_stream_mode_push" # Receive locally (push mode)
    fill_in "Password", :with => "alongsecret"

    click_button "Save"

    expect(current_url).to eq(incoming_stream_url)

    expect(page).to have_text("Transport mode : Receive locally (push mode)")
    expect(page).to have_text("Password : alongsecret")
  end

  scenario "User defines pull incoming stream" do
    visit "/incoming_stream/edit"

    choose "incoming_stream_mode_pull" # Retrieve from (pull mode)
    fill_in "incoming_stream_host", with: "localhost"
    fill_in "incoming_stream_port", with: "9000"

    fill_in "Password", :with => "alongsecret"

    click_button "Save"

    expect(current_url).to eq(incoming_stream_url)

    expect(page).to have_text("Transport mode : Retrieve from (pull mode)")
    expect(page).to have_text("Source : localhost:9000")
    expect(page).to have_text("Password : alongsecret")
  end
end
