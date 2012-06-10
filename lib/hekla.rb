require "hekla/monkey_patch"

require "hekla/config"
require "hekla/helpers"
require "hekla/log"
require "hekla/lorem_ipsum"

module Hekla
  extend Log
end

def d
  require "debugger"
  debugger
end
