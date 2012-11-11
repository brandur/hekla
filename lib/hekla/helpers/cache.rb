module Hekla::Helpers
  module Cache
    def cache
      if !Hekla::Config.production?
        yield
      else
        key = request.path_info
        key += "__pjax" if pjax?
        if cached = cache_store.get(key)
          log :cache_hit, path_info: request.path_info, key: key
          cached
        else
          log :cache_miss, key: key
          cached = yield
          cache_store.set(key, cached)
          cached
        end
      end
    end

    def cache_clear
      cache_store.flush if Hekla::Config.production?
    end

    def cache_store
      @store ||= Dalli::Client.new
    end
  end
end
