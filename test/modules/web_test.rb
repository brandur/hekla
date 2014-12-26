require_relative "../test_helper"

describe Hekla::Modules::Web do
  include Rack::Test::Methods

  def app
    Hekla::Main
  end

  let(:article)          { Article.new(valid_attributes) }
  let(:valid_attributes) {
    { title:        "About",
      slug:         "about",
      summary:      "About the Surf.",
      content:      "About the Surf.",
      published_at: Time.now.iso8601 }
  }

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

    it "caches an article on the client via If-Modified-Since" do
      get "/about", {},
        { "HTTP_IF_MODIFIED_SINCE" => article.updated_at.utc.httpdate }
      last_response.status.must_equal 304
      last_response.body.must_equal ""
    end

    it "caches an article on the client via If-None-Match" do
      tag = "1__/about__#{article.updated_at.utc.to_i}"
      get "/about", {}, { "HTTP_IF_NONE_MATCH" => "\"#{tag}\"" }
      last_response.status.must_equal 304
      last_response.body.must_equal ""
    end

    it "caches an article without layout on the client via If-None-Match" do
      tag = "1__/about__#{article.updated_at.utc.to_i}__pjax"
      get "/about", {}, { "HTTP_IF_NONE_MATCH" => "\"#{tag}\"", "X-PJAX" => true }
      last_response.status.must_equal 304
      last_response.body.must_equal ""
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
      attributes = valid_attributes.merge!(metadata: Sequel.hstore({ tiny_slug: "7" }))
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
