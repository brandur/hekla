class NilClass
  def blank?
    true
  end
end

class Object
  def to_json
    MultiJson.dump(self)
  end
end

class String
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def parse_json
    MultiJson.load(self)
  end
end
