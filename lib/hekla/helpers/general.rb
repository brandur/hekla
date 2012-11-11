module Hekla::Helpers
  module General
    def curl?
      !!(request.user_agent =~ /curl/)
    end

    def encode_json(obj)
      MultiJson.encode(obj, pretty: curl?)
    end

    def log(action, attrs = {})
      # REQUEST_ID inserted by rack-instruments
      Slides.log(action, attrs.merge!(id: request.env["REQUEST_ID"]))
    end
  end
end
