require "cgi"

module Hekla
  module Config
    extend self

    def disable_robots?
      @robots_disabled ||= %w{1 true yes}.include?(env("DISABLE_ROBOTS"))
    end

    def force_ssl?
      @force_ssl ||= %w{1 true yes}.include?(env("FORCE_SSL"))
    end

    def http_api_key
      @http_api_key ||= env!("HTTP_API_KEY")
    end

    def memcached_url
      user = env("MEMCACHIER_USERNAME")
      pass = env("MEMCACHIER_PASSWORD")
      url  = env("MEMCACHIER_SERVERS")
      if user && pass && url
        user = CGI.escape(user)
        pass = CGI.escape(pass)
        url  = CGI.escape(url)
        "memcached://#{user}:#{pass}@#{url}"
      else
        nil
      end
    end

    def production?
      rack_env == "production"
    end

    def release
      @release ||= env("RELEASE") || "1"
    end

    def root
      @root ||= File.expand_path("../../../", __FILE__)
    end

    def theme
      @theme ||= env!("THEME")
    end

    private

    def env(k)
      ENV[k] unless ENV[k].blank?
    end

    def env!(k)
      env(k) || raise("missing_environment=#{k}")
    end

    def rack_env
      @rack_env ||= env("RACK_ENV")
    end
  end
end
