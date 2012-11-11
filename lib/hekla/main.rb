module Hekla
  class Main < Sinatra::Base
    use Modules::Web
    use Modules::Assets
    use Modules::API
  end
end
