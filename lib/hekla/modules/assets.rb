module Hekla::Modules
  class Assets < Sinatra::Base
    configure do
      set :root, Hekla::Config.root
      set :assets, (Sprockets::Environment.new { |env|
        path = settings.root + "/themes/#{Hekla::Config.theme}/assets"
        Slides.log :assets, path: path

        env.append_path(path + "/images")
        env.append_path(path + "/javascripts")
        env.append_path(path + "/stylesheets")

        if ENV["RACK_ENV"] == "production"
          env.js_compressor  = YUI::JavaScriptCompressor.new
          env.css_compressor = YUI::CssCompressor.new
        end
      })
    end

    get "/assets/:release/app.js" do
      content_type("application/javascript")
      respond_with_asset(settings.assets["app.js"])
    end

    get "/assets/:release/app.css" do
      content_type("text/css")
      respond_with_asset(settings.assets["app.css"])
    end

    %w{jpg png}.each do |format|
      get "/assets/:image.#{format}" do |image|
        content_type("image/#{format}")
        respond_with_asset(settings.assets["#{image}.#{format}"])
      end
    end

    private

    def respond_with_asset(asset)
      last_modified(asset.mtime.utc)
      asset
    end
  end
end
