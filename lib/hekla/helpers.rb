module Hekla
  module Helpers
    def article_params
      metadata = if params[:attributes] && params[:content]
        eval(params[:attributes]).merge!({ content: params[:content] })
      else
        params[:article]
      end
      attrs, metadata = 
        metadata.split(:title, :slug, :summary, :content, :published_at)
      attrs.merge!({ metadata: metadata.hstore }) if metadata.count > 0
      attrs
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
        log :unauthorized
        throw(:halt, [401, { message: "Not authorized" }.to_json])
      end
    end

    def cache
      if Hekla::Config.development?
        yield
      else
        key = request.path_info
        key += "__pjax" if pjax?
        if cached = settings.cache.get(key)
          Scrolls.log :cache_hit, path_info: request.path_info, key: key
          cached
        else
          Scrolls.log :cache_miss, key: key
          cached = yield
          settings.cache.set(key, cached)
          cached
        end
      end
    end

    def cache_clear
      settings.cache.flush unless Hekla::Config.development?
    end

    # @todo: OMG HOLY SHIT FUGLY
    def link_to(*args)
      attrs = args.last.is_a?(Hash) ? args.pop : {}
      title = args[1] ? args[0] : nil
      uri   = args[1] ? args[1] : args[0]
      uri = uri.to_path if uri.kind_of?(Sequel::Model)
      attrs[:title] = title if title
      attr_str = attrs.map { |k, v| %{#{k}="#{v}"} }.join(" ")
      attr_str = " #{attr_str}" if attr_str.length > 0
      %{<a href="#{uri}" #{attr_str}>#{block_given? ? yield : title}</a>}
    end

    def log(action, attrs = {})
      Scrolls.log(action, attrs.merge!(id: request.id))
    end

    def pjax?
      !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
    end
  end
end
