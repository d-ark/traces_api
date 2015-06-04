ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'traces_api'
require 'rack/test'
require 'factory_girl'
FactoryGirl.definition_file_paths = %w(./spec/factories)
FactoryGirl.find_definitions


RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
