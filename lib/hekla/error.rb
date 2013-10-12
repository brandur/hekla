module Hekla
  class Error < StandardError
    attr_accessor :status

    def initialize(status, message)
      super(message)
      @status = status
    end
  end

  class BadRequest < Error
    def initialize(message)
      super(400, message)
    end
  end
end
