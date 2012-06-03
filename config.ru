require 'bundler/setup'
Bundler.require

# so logging output appears properly
$stdout.sync = true

# libs
$: << "./lib"
require "hekla"

# Sinatra app
require "./hekla"

require "sinatra/reloader" if Hekla.development?

configure do
  set :assets, settings.root + "/themes/#{Hekla::Config.theme}/assets"
  set :views,  settings.root + "/themes/#{Hekla::Config.theme}/views"
end
Hekla::log :assets, path: settings.assets
Hekla::log :views,  path: settings.views

# keep database connection separate from test suites
ActiveRecord::Base.establish_connection(Hekla::Config.database_url)

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
  run Sinatra::Application
end
