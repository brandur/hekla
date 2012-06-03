module Hekla
  module Log
    def log(action, attrs = {})
      puts "#{action} " + attrs.map { |k, v| unparse(k, v) }.join(" ")
    end

    private

    def unparse(k, v)
      # only quote strings if they include whitespace
      if v.is_a?(String) && v =~ /\s/
        %{#{k}="#{v}"}
      else
        "#{k}=#{v}"
      end
    end
  end
end
