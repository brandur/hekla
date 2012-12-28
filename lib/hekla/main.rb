module Hekla
  Main = Rack::Builder.new do
    use Rack::SSL if Hekla::Config.production?
    use Rack::Instruments
    use Rack::Cache,
      verbose: true,
      entitystore: Hekla::Config.memcached_url + "/body",
      metastore:   Hekla::Config.memcached_url + "/meta" \
      if Hekla::Config.memcached_url
    use Rack::Robots

    run Sinatra::Router.new {
      route Modules::Assets
      route Modules::API
      run Modules::Web
    }
  end
end
