module Hekla::Modules
  class Robots < Sinatra::Base
    #
    # Error handling
    #

    error do
      log_error(env['sinatra.error'])
      [500, "<h1>Internal server error</h1>"]
    end

    #
    # Routes
    #

    get "/robots.txt" do
      robots = "User-agent: *"
      if Hekla::Config.disable_robots?
        robots += "Disallow: /"
      else
        articles = Article.filter("metadata -> 'hidden' = 'true'")
        articles.each do |article|
          robots += "Disallow: /#{article.slug}"
        end
      end
      robots
    end
  end
end
