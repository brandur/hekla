xml.instruct! :xml, :version => "1.0" 
xml.feed "xml:lang" => "en-US", :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "Mutelight"
  xml.id "tag:mutelight.org,2009:/articles"
  xml.updated @articles.first ? @articles.first.published_at.rfc3339 : nil
  xml.link rel: "alternate", type: "text/html", href: "http://mutelight.org"
  xml.link rel: "self", type: "application/atom+xml", href: "http://mutelight.org/articles.atom"

  for article in @articles
    xml.entry do
      xml.title article.title
      xml.content article.content_html, type: "html"
      xml.published article.published_at.rfc3339
      xml.updated article.published_at.rfc3339
      xml.link href: "https://mutelight.org#{article.to_path}"
      xml.id "tag:mutelight.org,#{article.published_at.strftime('%F')}:#{article.to_path}"
      xml.author do
        xml.name "Brandur Leach"
        xml.uri "http://brandur.org"
      end
    end
  end
end
