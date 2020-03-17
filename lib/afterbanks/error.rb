module Afterbanks
  class Error < StandardError
    attr_reader :message, :additional_info

    def initialize(message:, additional_info: {})
      @message = message
      @additional_info = additional_info
    end
  end

  class IncorrectCallParameterError < Error; end
end
