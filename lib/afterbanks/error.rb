module Afterbanks
  class Error < ::StandardError
    attr_reader :message, :additional_info

    def initialize(message:, additional_info: nil)
      @message = message
      @additional_info = additional_info
    end
  end

  class GenericError < Error; end
  class ServiceUnavailableTemporarilyError < Error; end
  class ConnectionDataError < Error; end
  class AccountIdDoesNotExistError < Error; end
  class CutConnectionError < Error; end
  class HumanActionNeededError < Error; end
  class AccountIdNeededError < Error; end
  class OTPNeededError < Error; end
end
