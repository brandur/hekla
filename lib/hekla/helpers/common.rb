module Hekla::Helpers
  module Common
    def curl?
      !!(request.user_agent =~ /curl/)
    end

    def encode_json(obj)
      MultiJson.encode(obj, pretty: curl?)
    end

    def log(action, attrs = {})
      # REQUEST_ID inserted by rack-instruments
      Slides.log(action, attrs.merge!(request_id: request.env["REQUEST_IDS"]))
    end

    def log_error(e)
      log :error, type: e.class.name, message: e.message,
        backtrace: e.backtrace
    end

    def pjax?
      !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
    end
  end
end
