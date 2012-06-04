require "test_helper"
require "rack/test"

describe Hekla do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def valid_attributes
    { title:        "About",
      slug:         "about",
      summary:      "About the Surf.",
      content:      "About the Surf.",
      published_at: Time.now }
  end

  before do
    set :cache, stub!

    stub(Hekla::Config).theme { "the-surf" }
    set :views, settings.root + "/../themes/#{Hekla::Config.theme}/views"

    stub(Hekla::Config).http_api_key { "KEY" }
  end

  describe "GET /" do
    it "shows front page articles" do
      get "/"
      last_response.status.must_equal 200
    end
  end

  describe "GET /articles.atom" do
    it "provides an Atom feed" do
      get "/articles.atom"
      last_response.status.must_equal 200
      last_response.body.include?("http://www.w3.org/2005/Atom").must_equal true
    end
  end

  describe "GET /:id" do
    it "shows an article" do
      article = Article.new(valid_attributes)
      mock(Article).find_by_slug!("about") { article }
      get "/about"
      last_response.status.must_equal 200
      last_response.body.include?("<html").must_equal true
    end

   it "shows an article without layout" do
      article = Article.new(valid_attributes)
      mock(Article).find_by_slug!("about") { article }
      get "/about", {}, "X-PJAX" => true
  e
      last_response.status.must_equal 200
      last_response.body.include?("<html").must_equal false
   end
  end

  describe "GET /articles/:id" do
    it "redirects to /:id" do
      get "/articles/about"
      last_response.status.must_equal 302
    end
  end

  describe "POST /articles" do
    it "requires authorization" do
      post "/articles", { article: valid_attributes }
      last_response.status.must_equal 401
      last_response.body.parse_json["message"].must_equal "Not authorized"
    end

    it "creates an article" do
      authorize "", "KEY"
      any_instance_of(Article) { |a| mock(a).save { true } }
      post "/articles", { article: valid_attributes }
      last_response.status.must_equal 201
    end

    it "creates an article with file push" do
      authorize "", "KEY"
      any_instance_of(Article) { |a| mock(a).save { true } }
      time_str = "Time.parse(#{valid_attributes[:published_at]})"
      post "/articles", {
        attributes: valid_attributes.slice(:title, :summary).
          merge(published_at: time_str).to_s,
        content: valid_attributes[:content] }
      last_response.status.must_equal 201
    end

    it "fails to create an article" do
      authorize "", "KEY"
      any_instance_of(Article) { |a| mock(a).save { false } }
      post "/articles", { article: valid_attributes }
      last_response.status.must_equal 422
      last_response.body.parse_json.wont_equal nil
    end
  end

  describe "PUT /articles/:id" do
    it "requires authorization" do
      put "/articles/about", { article: valid_attributes }
      last_response.status.must_equal 401
      last_response.body.parse_json["message"].must_equal "Not authorized"
    end

    it "updates an article" do
      authorize "", "KEY"
      article = Article.new(valid_attributes)
      mock(article).save { true }
      mock(Article).find_by_slug!("about") { article }
      put "/articles/about", { article: valid_attributes }
      last_response.status.must_equal 204
    end

    it "updates an article with file push" do
      authorize "", "KEY"
      article = Article.new(valid_attributes)
      mock(article).save { true }
      mock(Article).find_by_slug!("about") { article }
      time_str = "Time.parse(#{valid_attributes[:published_at]})"
      put "/articles/about", {
        attributes: valid_attributes.slice(:title, :summary).
          merge(published_at: time_str).to_s,
        content: valid_attributes[:content] }
      last_response.status.must_equal 204
    end

    it "fails to update an article" do
      authorize "", "KEY"
      article = Article.new(valid_attributes)
      mock(article).save { false }
      mock(Article).find_by_slug!("about") { article }
      put "/articles/about", { article: valid_attributes }
      last_response.status.must_equal 422
      last_response.body.parse_json.wont_equal nil
    end
  end

  describe "DELETE /articles/:id" do
    it "requires authorization" do
      delete "/articles/about"
      last_response.status.must_equal 401
      last_response.body.parse_json["message"].must_equal "Not authorized"
    end

    it "deletes an article" do
      authorize "", "KEY"
      article = Article.new(valid_attributes)
      mock(article).destroy { true }
      mock(Article).find_by_slug!("about") { article }
      delete "/articles/about"
      last_response.status.must_equal 204
    end
  end
end
