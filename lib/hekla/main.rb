module Hekla
  Main = Rack::Builder.new do
    use Rack::SSL if Hekla::Config.force_ssl?
    use Rack::Instruments
    use Rack::Cache,
      verbose: true,
      entitystore: Hekla::Config.memcached_url + "/body",
      metastore:   Hekla::Config.memcached_url + "/meta" \
      if Hekla::Config.memcached_url
    use Rack::Robots

    run Sinatra::Router.new {
      mount Hekla::Modules::Assets
      mount Hekla::Modules::API
      run Hekla::Modules::Web
    }
  end
end
