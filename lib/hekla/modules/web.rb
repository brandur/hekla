module Hekla::Modules
  class Web < Sinatra::Base
    include Hekla::Helpers::Cache
    include Hekla::Helpers::General
    include Hekla::Helpers::Web

    configure do
      set :root,            Hekla::Config.root
      set :show_exceptions, false
      set :views,           settings.root + "/themes/#{Hekla::Config.theme}/views"
      Slides.log :views, path: settings.views
    end

    #
    # Filters
    #

    before do
      log :request_info, pjax: pjax?
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
      last_modified!(Article.ordered.first)
      cache do
        @articles = Article.ordered.limit(10)
        slim :index, layout: !pjax?
      end
    end

    get "/articles.atom" do
      last_modified!(Article.ordered.first)
      cache do
        @articles = Article.ordered.limit(20)
        builder :articles
      end
    end

    get "/archive" do
      last_modified!(Article.ordered.first)
      cache do
        @articles = Article.ordered.all.group_by { |a| a.published_at.year }
          .sort.reverse
        @title = "Archive"
        slim :archive, layout: !pjax?
      end
    end

    get "/:id.:format" do |id, format|
      Article.first(slug: id) || raise(Sinatra::NotFound)
      redirect to("/#{id}")
    end

    get "/:id" do |id|
      @article = Article.first(slug: id) || raise(Sinatra::NotFound)
      last_modified!(@article)
      cache do
        @title = @article.title
        slim :show, layout: !pjax?
      end
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
