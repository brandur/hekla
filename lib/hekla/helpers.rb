module Hekla
  module Helpers
    def article_params
      if params[:attributes] && params[:content]
        eval(params[:attributes]).merge!({ content: params[:content] })
      else
        params[:article]
      end.
        slice(:title, :slug, :summary, :content, :published_at)
    end

    def authenticate_with_http_basic
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
        yield(@auth.credentials)
    end

    def authorized?
      authenticate_with_http_basic do |username, password|
        password == Config.http_api_key
      end
    end

    def authorized!
      unless authorized?
        Hekla.log :unauthorized, ip: request.ip
        throw(:halt, [401, { message: "Not authorized" }.to_json])
      end
    end

    def cache
      if Hekla.development?
        yield
      else
        key = request.path_info
        key += "__pjax" if pjax?
        if cached = settings.cache.get(key)
          Hekla.log :cache_hit, path_info: request.path_info, key: key
          cached
        else
          Hekla.log :cache_miss, key: key
          cached = yield
          settings.cache.set(key, cached)
          cached
        end
      end
    end

    # @todo: OMG HOLY SHIT FUGLY
    def link_to(*args)
      attrs = args.last.is_a?(Hash) ? args.pop : {}
      title = args[1] ? args[0] : nil
      uri   = args[1] ? args[1] : args[0]
      uri = uri.to_path if uri.kind_of?(ActiveRecord::Base)
      attrs[:title] = title if title
      attr_str = attrs.map { |k, v| %{#{k}="#{v}"} }.join(" ")
      attr_str = " #{attr_str}" if attr_str.length > 0
      %{<a href="#{uri}" #{attr_str}>#{block_given? ? yield : title}</a>}
    end

    def pjax?
      !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
    end
  end
end
