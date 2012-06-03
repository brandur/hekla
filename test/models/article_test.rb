require "test_helper"

describe Article do
  def valid_attributes
    { title:        "About",
      slug:         "about",
      summary:      "About the Surf.",
      content:      "About the Surf.",
      published_at: Time.now }
  end

  describe "validations" do
    it "validates successfully" do
      Article.new(valid_attributes).valid?.must_equal true
    end

    it "validates presence of :title" do
      Article.new(valid_attributes.without(:title)).valid?.must_equal false
    end

    it "validates presence of :slug" do
      Article.new(valid_attributes.without(:slug)).valid?.must_equal false
    end

    it "validates presence of :content" do
      Article.new(valid_attributes.without(:content)).valid?.must_equal false
    end

    it "validates uniqueness of :slug" do
      Article.create!(valid_attributes)
      Article.new(valid_attributes).valid?.must_equal false
    end
  end

  it "uses its slug as its parameter" do
    Article.new(valid_attributes).to_param.must_equal valid_attributes[:slug]
  end

  it "renders content as markdown" do
    Article.new(:content => "**strong text**").content_html.must_equal \
      "<p><strong>strong text</strong></p>\n"
  end

  it "renders summary as markdown" do
    Article.new(:summary => "**strong text**").summary_html.must_equal \
      "<p><strong>strong text</strong></p>\n"
  end
end
