module Hekla::Modules
  class Default < Sinatra::Base
    #
    # Filters
    #

    before do
      log :request_info
    end

    #
    # Error handling
    #

    error do
      log_error(env['sinatra.error'])
      [404, "<h1>Not found</h1>"]
    end
  end
end
