require 'bundler/setup'
Bundler.require

require "minitest/spec"
require "minitest/autorun"
require "turn/autorun"
require "rr"

require_relative("../lib/hekla")
require_relative("../hekla")

class Hash
  def without(*args)
    self.reject { |k, v| args.include?(k) }
  end
end

class MiniTest::Spec
  include RR::Adapters::TestUnit

  before do
    Article.delete_all
  end
end

def e
  p last_response.errors
end

database_url = "postgres://localhost/the-surf-test"
ActiveRecord::Base.establish_connection(database_url)
