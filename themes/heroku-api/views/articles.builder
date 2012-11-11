xml.instruct! :xml, :version => "1.0" 
xml.feed "xml:lang" => "en-US", :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "Heroku API Development Blog"
  xml.id "tag:blog.api.heroku.com,2012:/articles"
  xml.updated @articles.first ? @articles.first.published_at.rfc3339 : nil
  xml.link rel: "alternate", type: "text/html", href: "https://the-surf.org"
  xml.link rel: "self", type: "application/atom+xml", href: "https://blog.api.heroku.com/articles.atom"

  for article in @articles
    xml.entry do
      xml.title article.title
      xml.content article.content_html, type: "html"
      xml.published article.published_at.rfc3339
      xml.updated article.published_at.rfc3339
      xml.link href: "https://blog.api.heroku.com#{article.to_path}"
      xml.id "tag:blog.api.heroku.com,#{article.published_at.strftime('%F')}:#{article.to_path}"
    end
  end
end
