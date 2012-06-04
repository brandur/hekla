require_relative "models/article"

helpers do
  def article_params
    if params[:attributes] && params[:content]
      eval(params[:attributes]).merge!({ content: params[:content] })
    else
      params[:article]
    end.
      slice(:title, :slug, :summary, :content, :published_at)
  end

  def article_url(article)
    "/#{article.to_param}"
  end

  def authenticate_with_http_basic
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials &&
      yield(@auth.credentials)
  end

  def authorized?
    authenticate_with_http_basic do |username, password|
      password == Hekla::Config.http_api_key
    end
  end

  def authorized!
    unless authorized?
      Hekla.log :unauthorized, ip: request.ip
      throw(:halt, [401, { message: "Not authorized" }.to_json])
    end
  end

  def pjax?
    !!request.env['X-PJAX']
  end
end

get "/" do
  Hekla.log :get_articles_index, pjax: pjax?
  @articles = Article.ordered.limit(10)
  slim :index, :layout => !pjax?
end

get "/articles.atom" do
  Hekla.log :get_articles_index, pjax: pjax?, format: "atom"
  @articles = Article.ordered.limit(20)
  builder :index
end

get "/archive" do
  Hekla.log :get_articles_archive, pjax: pjax?
  @articles = Article.ordered.group_by { |a| a.published_at.year }
    .sort.reverse
  slim :archive, :layout => !pjax?
end

get "/:id" do |id|
  Hekla.log :get_article, pjax: pjax?, id: id
  @article = Article.find_by_slug!(id)
  slim :show, :layout => !pjax?
end

get "/articles/:id" do |id|
  redirect to("/#{id}")
end

post "/articles" do
  Hekla.log :create_article
  authorized!
  @article = Article.new(article_params)
  if @article.save
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
  204
end
