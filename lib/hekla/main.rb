module Hekla
  Main = Rack::Builder.new do
    use Modules::Assets
    use Modules::API
    run Modules::Web
  end
end
