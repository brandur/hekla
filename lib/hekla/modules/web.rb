module Hekla::Modules
  class Web < Sinatra::Base
    include Hekla::Helpers::Cache
    include Hekla::Helpers::Common
    include Hekla::Helpers::Web

    configure do
      set :views, Hekla::Config.root + "/themes/#{Hekla::Config.theme}/views"
      Slim::Engine.set_default_options format: :html5, pretty: true
    end

    #
    # Filters
    #

    before do
      log :request_info, pjax: pjax?
      cache_control :public, :must_revalidate, max_age: 3600
    end

    #
    # Error handling
    #

    error do
      log_error(env['sinatra.error'])
      [500, "<h1>Internal server error</h1>"]
    end

    #
    # Routes
    #

    get "/" do
      articles = Article.index
      etag!(articles.first)
      last_modified!(articles.first)
      @articles = articles.limit(10)
      slim :index, layout: !pjax?
    end

    get "/articles.atom" do
      articles = Article.index
      etag!(articles.first)
      last_modified!(articles.first)
      @articles = articles.limit(20)
      builder :articles
    end

    get "/archive" do
      articles = Article.index
      etag!(articles.first)
      last_modified!(articles.first)
      @articles = articles.all.group_by { |a| a.published_at.year }
        .sort.reverse
      @title = "Archive"
      slim :archive, layout: !pjax?
    end

    get "/:id.:format" do |id, format|
      Article.first(slug: id) || raise(Sinatra::NotFound)
      redirect to("/#{id}")
    end

    get "/:id" do |id|
      @article = Article.first(slug: id) || raise(Sinatra::NotFound)
      etag!(@article)
      last_modified!(@article)
      @title = @article.title
      slim :show, layout: !pjax?
    end

    # redirect old style permalinks
    get "/articles/:id" do |id|
      log :get_article, old_permalink: true
      Article.first(slug: id) || raise(Sinatra::NotFound)
      redirect to("/#{id}")
    end

    get "/a/:id" do |id|
      log :get_article, tiny_slug: true
      @article = Article.first("metadata -> 'tiny_slug' = ?", id) ||
        raise(Sinatra::NotFound)
      redirect to(@article.to_path)
    end
  end
end
