require "test_helper"
require "rack/test"

describe Hekla do
  include Rack::Test::Methods

  let(:app)              { Sinatra::Application }
  let(:article)          { Article.new(valid_attributes) }
  let(:cache)            { CacheStub.new }
  let(:valid_attributes) {
    { title:        "About",
      slug:         "about",
      summary:      "About the Surf.",
      content:      "About the Surf.",
      published_at: Time.now }
  }

  before do
    set :cache, cache

    stub(Hekla::Config).theme { "the-surf" }
    set :views, settings.root + "/../themes/#{Hekla::Config.theme}/views"

    stub(Hekla::Config).http_api_key { "KEY" }

    # so we can test fancy stuff like caching
    stub(Hekla::Config).development? { false }
  end

  it "responds with a 404" do
    set :show_exceptions, false
    get "/does-not-exist"
    last_response.status.must_equal 404
  end

  describe "GET /" do
    it "shows front page articles" do
      mock(Article).ordered.times(any_times).mock! do |m|
        m.limit(10).times(any_times) { [article] }
        m.where.times(any_times).with_any_args.mock! do |m2|
          m2.first { article }
          m2.last { article }
        end
      end
      get "/"
      last_response.status.must_equal 200
    end
  end

  describe "GET /articles.atom" do
    it "provides an Atom feed" do
      mock(Article).ordered.mock!.limit(20) { [article] }
      get "/articles.atom"
      last_response.status.must_equal 200
      last_response.body.include?("http://www.w3.org/2005/Atom").must_equal true
    end
  end

  describe "GET /archive" do
    it "shows the archive" do
      mock(Article).ordered.mock!.all { [article] }
      get "/archive"
      last_response.status.must_equal 200
    end
  end

  describe "GET /robots.txt" do
    it "shows a robots file telling bots not to index the site" do
      get "/robots.txt"
      last_response.status.must_equal 200
      last_response.body.include?("Disallow: /").must_equal true
      last_response.headers["Content-Type"].must_equal "text/plain"
    end

    it "responds with a 404 in production" do
      stub(Hekla::Config).production? { true }
      get "/robots.txt"
      last_response.status.must_equal 404
    end
  end

  describe "GET /:id" do
    it "shows an article" do
      mock(Article).find_by_slug!("about") { article }
      get "/about"
      last_response.status.must_equal 200
      last_response.body.include?("<html").must_equal true
    end

    it "shows an article without layout" do
      mock(Article).find_by_slug!("about") { article }
      get "/about", {}, "X-PJAX" => true
      last_response.status.must_equal 200
      last_response.body.include?("<html").must_equal false
      last_response.body.include?("<title").must_equal true
    end

    it "caches an article" do
      mock(Article).find_by_slug!("about") { article }
      get "/about"
      last_response.status.must_equal 200
      cache.get("/about").include?("<html").must_equal true
    end

    it "caches an article without layout" do
      mock(Article).find_by_slug!("about") { article }
      get "/about", {}, "X-PJAX" => true
      last_response.status.must_equal 200
      cache.get("/about__pjax").include?("<html").must_equal false
      cache.get("/about__pjax").include?("<title").must_equal true
    end

    it "shows a cached article" do
      cache.set("/about", "About the Surf.")
      get "/about"
      last_response.status.must_equal 200
      last_response.body.must_equal "About the Surf."
    end

    it "shows a cached article without layout" do
      cache.set("/about__pjax", "About the Surf.")
      get "/about", {}, "X-PJAX" => true
      last_response.status.must_equal 200
      last_response.body.must_equal "About the Surf."
    end
  end

  describe "GET /articles/:id" do
    it "redirects to /:id" do
      get "/articles/about"
      last_response.status.must_equal 302
    end
  end

  describe "GET /a/:id" do
    it "redirects to an article if there was a tiny slug" do
      mock(Article).first.with_any_args { article }
      get "/a/7"
      last_response.status.must_equal 302
    end

    it "responds with 404 for a non-existent tiny slug" do
      get "/a/8"
      last_response.status.must_equal 404
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
      mock(article).save { true }
      mock(Article).new.with_any_args { article }
      post "/articles", { article: valid_attributes }
      e
      last_response.status.must_equal 201
    end

    it "creates an article with file push" do
      authorize "", "KEY"
      mock(article).save { true }
      mock(Article).new.with_any_args { article }
      time_str = "Time.parse(#{valid_attributes[:published_at]})"
      post "/articles", {
        attributes: valid_attributes.slice(:title, :summary).
          merge(published_at: time_str).to_s,
        content: valid_attributes[:content] }
      last_response.status.must_equal 201
    end

    it "fails to create an article" do
      authorize "", "KEY"
      mock(article).save { raise(Sequel::ValidationFailed.new([])) }
      mock(Article).new.with_any_args { article }
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
      mock(Article).find_by_slug!("about") { article }
      mock(article).save.with_any_args { true }
      put "/articles/about", { article: valid_attributes }
      last_response.status.must_equal 204
    end

    it "updates an article with file push" do
      authorize "", "KEY"
      mock(Article).find_by_slug!("about") { article }
      mock(article).save.with_any_args { true }
      time_str = "Time.parse(#{valid_attributes[:published_at]})"
      put "/articles/about", {
        attributes: valid_attributes.slice(:title, :summary).
          merge(published_at: time_str).to_s,
        content: valid_attributes[:content] }
      last_response.status.must_equal 204
    end

    it "fails to update an article" do
      authorize "", "KEY"
      mock(Article).find_by_slug!("about") { article }
      mock(article).save.with_any_args {
        raise(Sequel::ValidationFailed.new([]))
      }
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
