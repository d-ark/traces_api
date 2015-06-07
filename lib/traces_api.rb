require "nyny"
Rack::Utils.key_space_limit = 262144
require "traces_api/version"

require 'mongoid'
Mongoid.load!("mongoid.yml", NYNY::env)

Dir["./lib/mixins/*.rb"].each {|file| require file }
Dir["./lib/models/*.rb"].each {|file| require file }
Dir["./lib/apps/*.rb"].each {|file| require file }

module TracesApi
  class App < NYNY::App
    namespace '/traces', TracesApp
  end
end
