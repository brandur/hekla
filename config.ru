require "bundler/setup"
require "logger"
Bundler.require

# so logging output appears properly
$stdout.sync = true

# libs
$: << "./lib"
require "hekla"

# keep database connection separate from test suites
DB = Sequel.connect(Hekla::Config.database_url)

# Sinatra app
require "./hekla"

require "sinatra/reloader" if Hekla::Config.development?

configure do
  set :assets,          settings.root + "/themes/#{Hekla::Config.theme}/assets"
  set :cache,           Dalli::Client.new unless Hekla::Config.development?
  set :show_exceptions, false
  set :views,           settings.root + "/themes/#{Hekla::Config.theme}/views"
end
Slides.log :assets, path: settings.assets
Slides.log :views,  path: settings.views

Slim::Engine.set_default_options format: :html5, pretty: true

map "/assets" do
  assets = Sprockets::Environment.new do |env|
    env.append_path(settings.assets + "/images")
    env.append_path(settings.assets + "/javascripts")
    env.append_path(settings.assets + "/stylesheets")
    env.logger = Logger.new($stdout)
  end
  run assets
end

map "/" do
  use Rack::SSL if Hekla::Config.force_ssl?
  use Rack::Instruments
  use Rack::Robots
  run Sinatra::Application
end
