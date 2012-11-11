module Hekla::Helpers
  module Authentication
    def authenticate_with_http_basic
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
        yield(@auth.credentials)
    end

    def authorized?
      authenticate_with_http_basic do |username, password|
        password == Hekla::Config.http_api_key
      end
    end

    def authorized!
      unless authorized?
        log :unauthorized
        throw(:halt, [401, encode_json({ message: "Not authorized" })])
      end
    end
  end
end
