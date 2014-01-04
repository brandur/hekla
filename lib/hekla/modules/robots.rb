module Hekla::Modules
  class Robots < Sinatra::Base
    include Hekla::Helpers::Common

    #
    # Error handling
    #

    error do
      log_error(env['sinatra.error'])
      [500, "<h1>Internal server error</h1>"]
    end

    #
    # Filters
    #

    before do
      log :request_info
    end

    #
    # Routes
    #

    get "/robots.txt" do
      robots = "User-agent: *\n"
      if Hekla::Config.disable_robots?
        robots += "Disallow: /\n"
      else
        articles = Article.filter("metadata -> 'hidden' = 'true'").order("slug")
        articles.each do |article|
          robots += "Disallow: /#{article.slug}\n"
        end
      end
      [200, robots]
    end
  end
end
