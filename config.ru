require "bundler/setup"
Bundler.require

# so logging output appears properly
$stdout.sync = true

DB = Sequel.connect(ENV["DATABASE_URL"] ||
  raise("missing_environment=DATABASE_URL"))

require "./lib/hekla"

run Hekla::Main
