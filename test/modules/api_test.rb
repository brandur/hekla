require_relative "../test_helper"

describe Hekla::Modules::API do
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

  describe "POST /articles" do
    it "requires authorization" do
      post "/articles", { article: MultiJson.encode(valid_attributes) }
      last_response.status.must_equal 401
      last_json["message"].must_equal "Not authorized"
    end

    it "creates an article" do
      authorize "", "KEY"
      post "/articles", { article: MultiJson.encode(valid_attributes) }
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
      post "/articles", { article: MultiJson.encode(valid_attributes) }
      last_response.status.must_equal 422
      last_json.wont_equal nil
    end
  end

  describe "PUT /articles/:id" do
    before { article.save }

    it "requires authorization" do
      put "/articles/about", { article: MultiJson.encode(valid_attributes) }
      last_response.status.must_equal 401
      last_json["message"].must_equal "Not authorized"
    end

    it "updates an article" do
      authorize "", "KEY"
      put "/articles/about", { article: MultiJson.encode(valid_attributes) }
      last_response.status.must_equal 200
    end

    it "updates an article with file push" do
      authorize "", "KEY"
      time_str = "Time.parse(#{valid_attributes[:published_at]})"
      put "/articles/about", {
        attributes: valid_attributes.slice(:title, :summary).
          merge(published_at: time_str).to_s,
        content: valid_attributes[:content] }
      last_response.status.must_equal 200
    end

    it "fails to update an article" do
      authorize "", "KEY"
      mock(Article).first(slug: "about") { article }
      mock(article).update.with_any_args {
        raise(Sequel::ValidationFailed.new([]))
      }
      put "/articles/about", { article: MultiJson.encode(valid_attributes) }
      last_response.status.must_equal 422
      last_json.wont_equal nil
    end
  end

  describe "DELETE /articles/:id" do
    before { article.save }

    it "requires authorization" do
      delete "/articles/about"
      last_response.status.must_equal 401
      last_json["message"].must_equal "Not authorized"
    end

    it "deletes an article" do
      authorize "", "KEY"
      delete "/articles/about"
      last_response.status.must_equal 200
    end
  end

  private

  def last_json
    MultiJson.decode(last_response.body)
  end
end
