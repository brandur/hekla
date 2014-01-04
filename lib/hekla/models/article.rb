class Article < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  def self.index
    filter("not metadata ? 'hidden' or metadata -> 'hidden' != 'true'").
      reverse_order(:published_at)
  end

  def content_html
    render_markdown(content)
  end

  def next
    Article.index.where("published_at > ?", published_at).last
  end

  def prev
    Article.index.where("published_at < ?", published_at).first
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
