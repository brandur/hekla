require 'bundler/setup'
Bundler.require(:default, :test)

require "minitest/spec"
require "minitest/autorun"
require "turn/autorun"
require "rr"

ENV["HTTP_API_KEY"] = "KEY"
ENV["RACK_ENV"]     = "test"
ENV["THEME"]        = "the-surf"

database_url = "postgres://localhost/the-surf-test"
DB = Sequel.connect(database_url)

require_relative "../lib/hekla"

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

  before do
    Article.delete
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

def e
  p last_response.errors
end
