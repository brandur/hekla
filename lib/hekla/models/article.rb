class Article < Sequel::Model
  plugin :validation_helpers

  def self.find_by_slug(s)
    filter(slug: s).first
  end

  def self.find_by_slug!(s)
    find_by_slug(s) || raise(Sinatra::NotFound)
  end

  def self.ordered
    reverse_order(:published_at)
  end

  def content_html
    render_markdown(content)
  end

  def next
    Article.ordered.where("published_at > ?", published_at).last
  end

  def prev
    Article.ordered.where("published_at < ?", published_at).first
  end

  def summary_html
    summary ? render_markdown(summary) : nil
  end

  def to_path
    "/#{slug}"
  end

  def validate
    super
    validates_presence [:title, :slug, :content, :published_at]
    validates_unique [:slug]
  end

  #
  # Serialization
  #

  def v1_attributes
    values.merge(published_at: published_at.iso8601)
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
