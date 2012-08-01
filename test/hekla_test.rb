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
      published_at: Time.now.iso8601 }
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
    before { article.save }

    it "shows front page articles" do
      get "/"
      last_response.status.must_equal 200
    end
  end

  describe "GET /articles.atom" do
    before { article.save }

    it "provides an Atom feed" do
      get "/articles.atom"
      last_response.status.must_equal 200
      last_response.body.include?("http://www.w3.org/2005/Atom").must_equal true
    end
  end

  describe "GET /archive" do
    before { article.save }

    it "shows the archive" do
      get "/archive"
      last_response.status.must_equal 200
    end
  end

  describe "GET /:id.:format" do
    before { article.save }

    it "redirects to an article if a format was specified" do
      get "/about.html"
      last_response.status.must_equal 302
    end

    it "responds with a 404 if that article did not exist" do
      get "/not-about.html"
      last_response.status.must_equal 404
    end
  end

  describe "GET /:id" do
    before { article.save }

    it "shows an article" do
      get "/about"
      last_response.status.must_equal 200
      last_response.body.include?("<html").must_equal true
    end

    it "shows an article without layout" do
      get "/about", {}, "X-PJAX" => true
      last_response.status.must_equal 200
      last_response.body.include?("<html").must_equal false
      last_response.body.include?("<title").must_equal true
    end

    it "caches an article" do
      get "/about"
      last_response.status.must_equal 200
      cache.get("/about").include?("<html").must_equal true
    end

    it "caches an article without layout" do
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
    before { article.save }

    it "redirects to /:id" do
      get "/articles/about"
      last_response.status.must_equal 302
    end

    it "responds with 404 if the article did not exist" do
      get "/articles/not-about"
      last_response.status.must_equal 404
    end
  end

  describe "GET /a/:id" do
    before do
      attributes = valid_attributes.merge!(metadata: { tiny_slug: "7" }.hstore)
      Article.new(attributes).save
    end

    it "redirects to an article if there was a tiny slug" do
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
      post "/articles", { article: valid_attributes.to_json }
      last_response.status.must_equal 401
      last_response.body.parse_json["message"].must_equal "Not authorized"
    end

    it "creates an article" do
      authorize "", "KEY"
      post "/articles", { article: valid_attributes.to_json }
      last_response.status.must_equal 201
    end

    it "creates an article with file push" do
      authorize "", "KEY"
      time_str = "Time.parse(#{valid_attributes[:published_at]})"
      post "/articles", {
        attributes: valid_attributes.slice(:title, :slug, :summary).
          merge(published_at: time_str).to_s,
        content: valid_attributes[:content] }
      last_response.status.must_equal 201
    end

    it "fails to create an article" do
      authorize "", "KEY"
      mock(article).save { raise(Sequel::ValidationFailed.new([])) }
      mock(Article).new.with_any_args { article }
      post "/articles", { article: valid_attributes.to_json }
      last_response.status.must_equal 422
      last_response.body.parse_json.wont_equal nil
    end
  end

  describe "PUT /articles/:id" do
    before { article.save }

    it "requires authorization" do
      put "/articles/about", { article: valid_attributes.to_json }
      last_response.status.must_equal 401
      last_response.body.parse_json["message"].must_equal "Not authorized"
    end

    it "updates an article" do
      authorize "", "KEY"
      put "/articles/about", { article: valid_attributes.to_json }
      last_response.status.must_equal 204
    end

    it "updates an article with file push" do
      authorize "", "KEY"
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
      mock(article).update.with_any_args {
        raise(Sequel::ValidationFailed.new([]))
      }
      put "/articles/about", { article: valid_attributes.to_json }
      last_response.status.must_equal 422
      last_response.body.parse_json.wont_equal nil
    end
  end

  describe "DELETE /articles/:id" do
    before { article.save }

    it "requires authorization" do
      delete "/articles/about"
      last_response.status.must_equal 401
      last_response.body.parse_json["message"].must_equal "Not authorized"
    end

    it "deletes an article" do
      authorize "", "KEY"
      delete "/articles/about"
      last_response.status.must_equal 204
    end
  end
end
