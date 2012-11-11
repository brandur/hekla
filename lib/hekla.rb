require_relative "hekla/monkey_patch"

require_relative "hekla/config"
require_relative "hekla/helpers"
require_relative "hekla/lorem_ipsum"

require_relative "hekla/models/article"

require_relative "hekla/modules/assets"
require_relative "hekla/modules/web"

require_relative "hekla/main"

def d
  require "debugger"
  debugger
end
