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
  slim :index, :layout => !pjax?
end

get "/archive" do
  slim :archive, :layout => !pjax?
end

get "/:article" do
  slim :article, :layout => !pjax?
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
