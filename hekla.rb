require_relative "models/article"

helpers do
  include Hekla::Helpers
end

error Sequel::ValidationFailed do
  [422, @article.errors.flatten.to_json]
end

get "/" do
  log :get_articles_index, pjax: pjax?
  cache do
    @articles = Article.ordered.limit(10)
    slim :index, layout: !pjax?
  end
end

get "/articles.atom" do
  log :get_articles_index, pjax: pjax?, format: "atom"
  cache do
    @articles = Article.ordered.limit(20)
    builder :articles
  end
end

get "/archive" do
  log :get_articles_archive, pjax: pjax?
  cache do
    @articles = Article.ordered.all.group_by { |a| a.published_at.year }
      .sort.reverse
    @title = "Archive"
    slim :archive, layout: !pjax?
  end
end

get "/robots.txt" do
  log :get_robots, robots_disabled: Hekla::Config.disable_robots?
  if Hekla::Config.disable_robots?
    [200, { 'Content-Type' => 'text/plain' }, <<-eos]
  # this is a staging environment. please index the main site instead.
  User-agent: *
  Disallow: /
    eos
  else
    raise(Sinatra::NotFound)
  end
end

get "/:id.:format" do |id, format|
  log :get_article, pjax: pjax?, id: id, format: true
  redirect to("/#{id}")
end

get "/:id" do |id|
  log :get_article, pjax: pjax?, id: id
  cache do
    @article = Article.find_by_slug!(id)
    @title = @article.title
    slim :show, layout: !pjax?
  end
end

# redirect old style permalinks
get "/articles/:id" do |id|
  log :get_article, pjax: pjax?, id: id, old_permalink: true
  redirect to("/#{id}")
end

get "/a/:id" do |id|
  log :get_article, pjax: pjax?, id: id, tiny_slug: true
  @article = Article.first("metadata -> 'tiny_slug' = ?", id) ||
    raise(Sinatra::NotFound)
  redirect to(@article.to_path)
end

post "/articles" do
  log :create_article
  authorized!
  @article = Article.new(article_params)
  @article.save
  cache_clear
  [201, @article.to_json]
end

put "/articles/:id" do |id|
  log :update_article, id: id
  authorized!
  @article = Article.find_by_slug!(id)
  @article.update(article_params)
  cache_clear
  204
end

delete "/articles/:id" do |id|
  log :destroy_article, id: id
  authorized!
  @article = Article.find_by_slug!(id)
  @article.destroy
  cache_clear
  204
end
