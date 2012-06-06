require "test_helper"

describe Hash do
  describe "#split" do
    it "splits on a set of keys into two hashes" do
      h = { a: 1, b: 2, c: 3, d: 4 }
      h1, h2 = h.split(:a, :b, :c)
      h1.must_equal({ a: 1, b: 2, c: 3 })
      h2.must_equal({ d: 4})
    end
  end
end

describe Time do
  describe "#rfc822" do
    it "produces RFC822 compliant times" do
      Time.new.to_rfc822.wont_equal nil
    end
  end
end
