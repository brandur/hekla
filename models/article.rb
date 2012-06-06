class Article < Sequel::Model
  plugin :validation_helpers

  def self.find_by_slug!(s)
    filter(slug: s).first || raise(Sinatra::NotFound)
  end

  def self.ordered
    reverse_order(:published_at)
  end

  def content_html
    render_markdown(content)
  end

  def summary_html
    render_markdown(summary)
  end

  def to_json
    values.merge({published_at: published_at.iso8601}).to_json
  end

  def to_path
    "/#{slug}"
  end

  def validate
    super
    validates_presence [:title, :slug, :content, :published_at]
    validates_unique [:slug]
  end

  private

  def render_markdown(str)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
      :fenced_code_blocks => true, :hard_wrap => true)

    # Redcarpet now allows a new renderer to be defined. This would be better.
    renderer.render(str).
      gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
  end
end
