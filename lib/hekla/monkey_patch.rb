class Hash
  def split(*keys)
    new_hash = select { |k, v| keys.include?(k) }
    return new_hash, delete_if { |k, v| keys.include?(k) }
  end

  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
end

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

class Time
  def to_rfc822
    strftime("%a, %d %b %Y %H:%M:%S %z")
  end
end
