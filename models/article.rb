class Article < ActiveRecord::Base
  scope :ordered, order('published_at DESC')
  validates_presence_of :title, :slug, :content, :summary, :published_at
  validates_uniqueness_of :slug

  def content_html
    render_markdown(content)
  end

  def summary_html
    render_markdown(summary)
  end

  def to_path
    "/#{slug}"
  end

  private

  def render_markdown(str)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
      :fenced_code_blocks => true, :hard_wrap => true)
    renderer.render(str)
  end
end
