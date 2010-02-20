# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_linkcontrol_session',
  :secret      => '3779d7780d6fc1983ccb040d0b9b67e0dda0ec16db9799f3e7b44cda81e40713b14ac0b4f0157abd9d5e8de0a21a6ad2e9917dd6259a649bd330b2744775ab85'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
