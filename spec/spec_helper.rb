$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'webmock/rspec'
require "afterbanks"

def response_json(resource:, action:)
  path = File.join('spec', 'responses', resource, "#{action}.json")
  File.read(path)
end

def configure_afterbanks
  Afterbanks.configure do |config|
    config.servicekey = 'a_servicekey_which_works'
  end
end
