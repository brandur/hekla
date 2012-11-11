module Hekla::Modules
  class API < Sinatra::Base
    include Hekla::Helpers::API
    include Hekla::Helpers::Authentication
    include Hekla::Helpers::Cache
    include Hekla::Helpers::General

    configure do
      set :show_exceptions, false
    end

    #
    # Error handling
    #

    error Sequel::ValidationFailed do
      [422, encode_json(@article.errors.flatten)]
    end

    error do
      log :error, type: env['sinatra.error'].class.name,
        message: env['sinatra.error'].message,
        backtrace: env['sinatra.error'].backtrace
      [500, encode_json({ message: "Internal server error" })]
    end

    #
    # Routes
    #

    post "/articles" do
      authorized!
      @article = Article.new(article_params)
      @article.save
      cache_clear
      [201, encode_json(@article)]
    end

    put "/articles/:id" do |id|
      authorized!
      @article = Article.find_by_slug!(id)
      @article.update(article_params)
      cache_clear
      [200, encode_json(@article)]
    end

    delete "/articles/:id" do |id|
      authorized!
      @article = Article.find_by_slug!(id)
      @article.destroy
      cache_clear
      [200, encode_json(@article)]
    end
  end
end
