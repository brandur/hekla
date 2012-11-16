require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

DB = Sequel.connect(ENV["DATABASE_URL"] ||
  raise("missing_environment=DATABASE_URL"))

require "./lib/hekla"

require "sinatra/reloader" if !Hekla::Config.production?

Slim::Engine.set_default_options format: :html5, pretty: true

use Rack::SSL if Hekla::Config.production?
use Rack::Instruments
use Rack::Robots
run Hekla::Main
