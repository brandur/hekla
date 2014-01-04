require_relative "common"

module Hekla::Helpers
  module Cache
    include Common

    def etag!(article)
      return if !article || Hekla::Config.development?
      tag = [
        Hekla::Config.release,
        request.path_info,
        article.updated_at.utc.to_i,
        pjax? ? "pjax" : nil,
      ].compact.join("__")
      etag(tag)
    end

    def last_modified!(article)
      return if !article || Hekla::Config.development?
      last_modified(article.updated_at.utc)
    end
  end
end
