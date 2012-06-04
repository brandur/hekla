require "hekla/monkey_patch"

require "hekla/config"
require "hekla/log"
require "hekla/lorem_ipsum"

module Hekla
  extend Log

  def self.development?
    env == "development"
  end

  def self.env
    ENV["RACK_ENV"]
  end
end

def d
  require "debugger"
  debugger
end
