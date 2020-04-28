module Afterbanks
  class Response
    attr_accessor :result, :debug_id

    def initialize(result:, debug_id:)
      @result = result
      @debug_id = debug_id
    end
  end
end
