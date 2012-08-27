require_relative "models/article"

helpers do
  include Hekla::Helpers
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
# Public
#

get "/" do
  cache do
    @articles = Article.ordered.limit(10)
    slim :index, layout: !pjax?
  end
end

get "/articles.atom" do
  cache do
    @articles = Article.ordered.limit(20)
    builder :articles
  end
end

get "/archive" do
  cache do
    @articles = Article.ordered.all.group_by { |a| a.published_at.year }
      .sort.reverse
    @title = "Archive"
    slim :archive, layout: !pjax?
  end
end

get "/:id.:format" do |id, format|
  redirect to("/#{id}") if Article.find_by_slug(id)
  raise(Sinatra::NotFound)
end

get "/:id" do |id|
  cache do
    @article = Article.find_by_slug!(id)
    @title = @article.title
    slim :show, layout: !pjax?
  end
end

# redirect old style permalinks
get "/articles/:id" do |id|
  log :get_article, old_permalink: true
  redirect to("/#{id}") if Article.find_by_slug(id)
  raise(Sinatra::NotFound)
end

get "/a/:id" do |id|
  log :get_article, tiny_slug: true
  @article = Article.first("metadata -> 'tiny_slug' = ?", id) ||
    raise(Sinatra::NotFound)
  redirect to(@article.to_path)
end

#
# API
#

post "/articles" do
  authorized!
  @article = Article.new(article_params)
  @article.save
  cache_clear
  [201, @article.to_json]
end

put "/articles/:id" do |id|
  authorized!
  @article = Article.find_by_slug!(id)
  @article.update(article_params)
  cache_clear
  [200, @article.to_json]
end

delete "/articles/:id" do |id|
  authorized!
  @article = Article.find_by_slug!(id)
  @article.destroy
  cache_clear
  [200, @article.to_json]
end
