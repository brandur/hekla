module Hekla::Modules
  class Assets < Sinatra::Base
    def initialize(*args)
      super
      path = "#{Hekla::Config.root}/themes/#{Hekla::Config.theme}/assets"
      @assets = Sprockets::Environment.new do |env|
        Slides.log :assets, path: path

        env.append_path(path + "/images")
        env.append_path(path + "/javascripts")
        env.append_path(path + "/stylesheets")

        if Hekla::Config.production?
          env.js_compressor  = YUI::JavaScriptCompressor.new
          env.css_compressor = YUI::CssCompressor.new
        end
      end
    end

    get "/assets/:release/app.css" do
      respond_with_asset(@assets["app.css"])
    end

    get "/assets/:release/app.js" do
      respond_with_asset(@assets["app.js"])
    end

    %w{jpg png}.each do |format|
      get "/assets/:image.#{format}" do |image|
        respond_with_asset(@assets["#{image}.#{format}"])
      end
    end

    private

    def respond_with_asset(asset)
      cache_control(:public, max_age: 2592000)
      content_type(asset.content_type)
      last_modified(asset.mtime.utc)
      asset
    end
  end
end
