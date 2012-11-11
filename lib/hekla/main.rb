module Hekla
  class Main < Sinatra::Base
    use Modules::Assets
    use Modules::Web
  end
end
