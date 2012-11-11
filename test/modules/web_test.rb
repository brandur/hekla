require_relative "../test_helper"

describe Hekla::Modules::Web do
  include Rack::Test::Methods

  def app
    Hekla::Main
  end

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
    stub(Dalli::Client).new { cache }
  end

  it "responds with a 404" do
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
end
