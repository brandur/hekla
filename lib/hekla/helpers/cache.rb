module Hekla::Helpers
  module Cache
    def etag!(article)
      return unless article
      tag = [
        Hekla::Config.release,
        request.path_info,
        article.updated_at.utc.to_i,
        pjax? ? "pjax" : nil,
      ].compact.join("__")
      etag(tag)
    end

    def last_modified!(article)
      return unless article
      last_modified(article.updated_at.utc)
    end
  end
end
