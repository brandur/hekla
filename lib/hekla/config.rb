module Hekla
  module Config
    extend self

    def database_url
      @database_url ||= env!("DATABASE_URL")
    end

    def http_api_key
      @http_api_key ||= env!("HTTP_API_KEY")
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
  end
end
