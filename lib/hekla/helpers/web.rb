module Hekla::Helpers
  module Web
    def last_modified!(article)
      last_modified(article.updated_at.utc) if article
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

    def pjax?
      !!(request.env["X-PJAX"] || request.env["HTTP_X_PJAX"])
    end
  end
end
