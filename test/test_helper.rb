ENV["DATABASE_URL"]   = "postgres://localhost/hekla-test"
ENV["DISABLE_ROBOTS"] = "false"
ENV["FORCE_SSL"]      = "false"
ENV["HTTP_API_KEY"]   = "KEY"
# make sure to set RACK_ENV=test before requiring Sinatra
ENV["RACK_ENV"]       = "test"
ENV["RELEASE"]        = "1"
ENV["THEME"]          = "the-surf"

require 'bundler/setup'
Bundler.require(:default, :test)

require "minitest/spec"
require 'minitest/pride'
require "minitest/autorun"
require "rr"

# suppress logging
unless ENV["TEST_LOGS"] == "true"
  module Slides
    def self.log(*_)
      yield if block_given?
    end
  end
end

DB = Sequel.connect(ENV["DATABASE_URL"])

require_relative "../lib/hekla"

# @todo: remove all this
class Hash
  def slice(*args)
    self.reject { |k, v| !args.include?(k) }
  end

  def without(*args)
    self.reject { |k, v| args.include?(k) }
  end
end

class MiniTest::Spec
  include RR::Adapters::TestUnit

  # wrap each test in a transaction to clean the database on completion
  def run(*args, &block)
    value = nil
    begin
      DB.transaction do
        value = super
        raise Sequel::Rollback
      end
    rescue Sequel::Rollback
    end
    value
  end
end

# disable Sequel logging in tests because it's extremely verbose
module ::Sequel
  class Database
    def log_yield(sql, args=nil)
      yield
    end
  end
end
