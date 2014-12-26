require_relative "../test_helper"

describe Hekla::Helpers::API do
  include Hekla::Helpers::API

  describe "#article_params" do
    def params
      { article: MultiJson.encode({
        title:        "About",
        slug:         "about",
        summary:      "About the Surf.",
        content:      "About the Surf.",
        published_at: "today",
        other:        "random!",
      }) }
    end

    it "receives a standard article hash" do
      article_params.must_equal({
        title:        "About",
        slug:         "about",
        summary:      "About the Surf.",
        content:      "About the Surf.",
        published_at: "today",
        metadata:     Sequel.hstore({ other: "random!" }),
      })
    end
  end
end

describe Hekla::Helpers::API do
  include Hekla::Helpers::API

  describe "#article_params" do
    def attributes
      <<-eos
        { title:        "About",
          slug:         "about",
          summary:      "About the Surf.",
          published_at: "today",
          other:        "random!",
        }
      eos
    end

    def params
      { attributes: attributes,
        content: "About the Surf.",
      }
    end

    it "receives a special Ruby file and contents" do
      article_params.must_equal({
        title:        "About",
        slug:         "about",
        summary:      "About the Surf.",
        content:      "About the Surf.",
        published_at: "today",
        metadata:     Sequel.hstore({ other: "random!" }),
      })
    end
  end
end
