module Hekla
  Main = Rack::Builder.new do
    use Rack::SSL if Hekla::Config.force_ssl?
    use Rack::Instruments
    use Rack::Deflater
    use Rack::Cache,
      verbose:     true,
      metastore:   'file:/tmp/cache/meta',
      entitystore: 'file:/tmp/cache/entity' if Config.production?

    run Sinatra::Router.new {
      mount Hekla::Modules::Assets
      mount Hekla::Modules::API
      mount Hekla::Modules::Robots
      mount Hekla::Modules::Web
      run Hekla::Modules::Default
    }
  end
end
