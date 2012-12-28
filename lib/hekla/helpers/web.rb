module Hekla::Helpers
  module Web
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
  end
end
