module Hekla::Modules
  class API < Sinatra::Base
    include Hekla::Helpers

    configure do
      set :show_exceptions, false
    end

    #
    # Error handling
    #

    error Sequel::ValidationFailed do
      [422, @article.errors.flatten.to_json]
    end

    error do
      log :error, type: env['sinatra.error'].class.name,
        message: env['sinatra.error'].message,
        backtrace: env['sinatra.error'].backtrace
      [500, { message: "Internal server error" }.to_json]
    end

    #
    # Routes
    #

    post "/articles" do
      authorized!
      @article = Article.new(article_params)
      @article.save
      cache_clear
      [201, @article.to_json(pretty: curl?)]
    end

    put "/articles/:id" do |id|
      authorized!
      @article = Article.find_by_slug!(id)
      @article.update(article_params)
      cache_clear
      [200, @article.to_json(pretty: curl?)]
    end

    delete "/articles/:id" do |id|
      authorized!
      @article = Article.find_by_slug!(id)
      @article.destroy
      cache_clear
      [200, @article.to_json(pretty: curl?)]
    end
  end
end
