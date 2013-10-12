module Hekla::Helpers
  module API

    def article_params
      metadata = if params[:attributes] && params[:content]
        eval(params[:attributes]).merge!({ content: params[:content] })
      elsif params[:content]
        if params[:content] =~ /\A(---\n.*?\n---)\n(.*)\Z/m
          Psych.load($1).merge({ content: $2.strip })
        else
          raise Hekla::BadRequest.new("Require front matter metadata.")
        end
      else
        begin
          MultiJson.decode(params[:article])
        rescue MultiJson::LoadError
          raise Hekla::BadRequest.new("Couldn't parse JSON.")
        end
      end
      metadata.symbolize_keys!
      attrs, metadata =
        metadata.split(:title, :slug, :summary, :content, :published_at)
      attrs.merge!({ metadata: metadata.hstore }) if metadata.count > 0
      attrs
    end
  end
end
