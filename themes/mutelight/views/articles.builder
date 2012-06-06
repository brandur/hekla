xml.instruct! :xml, :version => "1.0" 
xml.feed "xml:lang" => "en-US", :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "The Surf"
  xml.id "tag:the-surf.org:/articles"
  xml.updated @articles.first ? @articles.first.published_at.to_rfc822 : nil
  xml.link rel: "alternate", type: "text/html", href: "http://the-surf.org"
  xml.link rel: "self", type: "application/atom+xml", href: "http://the-surf.org/articles.atom"

  for article in @articles
    xml.entry do
      xml.title article.title
      xml.content article.content_html, type: "html"
      xml.published article.published_at.to_rfc822
      xml.updated article.published_at.to_rfc822
      xml.link "http://the-surf.org#{article.to_path}"
      xml.id "tag:the-surf.org,#{article.published_at.strftime('%F')}:http://the-surf.org#{article.to_path}.html"
      xml.author do
        xml.name "Brandur Leach"
        xml.uri "http://brandur.org"
      end
    end
  end
end
