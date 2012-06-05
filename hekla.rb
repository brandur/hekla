require_relative "models/article"

helpers do
  include Hekla::Helpers
end

error ActiveRecord::RecordNotFound do
  404
end

get "/" do
  Hekla.log :get_articles_index, pjax: pjax?
  cache do
    @articles = Article.ordered.limit(10)
    slim :index, layout: !pjax?
  end
end

get "/articles.atom" do
  Hekla.log :get_articles_index, pjax: pjax?, format: "atom"
  cache do
    @articles = Article.ordered.limit(20)
    builder :articles
  end
end

get "/archive" do
  Hekla.log :get_articles_archive, pjax: pjax?
  cache do
    @articles = Article.ordered.group_by { |a| a.published_at.year }
      .sort.reverse
    @title = "Archive"
    slim :archive, layout: !pjax?
  end
end

get "/:id" do |id|
  Hekla.log :get_article, pjax: pjax?, id: id
  cache do
    @article = Article.find_by_slug!(id)
    @title = @article.title
    slim :show, layout: !pjax?
  end
end

# redirect old style permalinks
get "/articles/:id" do |id|
  Hekla.log :get_article, pjax: pjax?, id: id, old_permalink: true
  redirect to("/#{id}")
end

post "/articles" do
  Hekla.log :create_article
  authorized!
  @article = Article.new(article_params)
  if @article.save
    cache_clear
    [201, @article.to_json]
  else
    [422, @article.errors.to_json]
  end
end

put "/articles/:id" do |id|
  Hekla.log :update_article, id: id
  authorized!
  @article = Article.find_by_slug!(id)
  if @article.update_attributes(article_params)
    cache_clear
    204
  else
    [422, @article.errors.to_json]
  end
end

delete "/articles/:id" do |id|
  Hekla.log :destroy_article, id: id
  authorized!
  @article = Article.find_by_slug!(id)
  @article.destroy
  cache_clear
  204
end
