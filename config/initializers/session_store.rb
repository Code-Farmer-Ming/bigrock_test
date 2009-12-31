# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_BigRockApplication_session',
  :secret      => '71aa4e87f6fe7f19c881d3154fa68deaaf0b8f1528f627f643ae0ec9d0676171edd007b48499eab109daf01001b352338dffb996f5e43335f55c51f6903a2ea4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
