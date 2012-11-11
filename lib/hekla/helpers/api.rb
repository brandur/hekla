module Hekla::Helpers
  module API
    def article_params
      metadata = if params[:attributes] && params[:content]
        eval(params[:attributes]).merge!({ content: params[:content] })
      else
        MultiJson.decode(params[:article])
      end
      metadata.symbolize_keys!
      attrs, metadata =
        metadata.split(:title, :slug, :summary, :content, :published_at)
      attrs.merge!({ metadata: metadata.hstore }) if metadata.count > 0
      attrs
    end
  end
end
