require_relative "models/article"

Slim::Engine.set_default_options format: :html5, pretty: true, disable_escape: true

helpers do
  def article_params
    if params[:attributes] && params[:content]
      eval(params[:attributes]).merge!({ content: params[:content] })
    else
      params[:article]
    end.
      slice(:title, :slug, :summary, :content, :published_at)
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

  def link_to(title, uri, attrs = {})
    uri = uri.to_path if uri.kind_of?(ActiveRecord::Base)
    attr_str = attrs.map { |k, v| %{#{k}="#{v}"} }.join(" ")
    attr_str = " #{attr_str}" if attr_str.length > 0
    %{<a href="#{uri}" title="#{title}"#{attr_str}>#{title}</a>}
  end

  def pjax?
    !!request.env['X-PJAX']
  end
end

get "/" do
  Hekla.log :get_articles_index, pjax: pjax?
  @articles = Article.ordered.limit(10)
  Hekla.log :found_articles, count: @articles.count
  slim :index, layout: !pjax?
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
  @title = "Archive"
  slim :archive, layout: !pjax?
end

get "/:id" do |id|
  Hekla.log :get_article, pjax: pjax?, id: id
  @article = Article.find_by_slug!(id)
  @title = @article.title
  slim :show, layout: !pjax?
end

# redirect old style permalinks
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
