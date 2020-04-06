module Afterbanks
  class Error < ::StandardError
    attr_reader :message, :additional_info

    def initialize(message:, additional_info: nil)
      @message = message
      @additional_info = additional_info
    end

    def code
      raise 'Not implemented'
    end
  end

  class GenericError < Error
    def code
      1
    end
  end

  class ServiceUnavailableTemporarilyError < Error
    def code
      2
    end
  end

  class ConnectionDataError < Error
    def code
      3
    end
  end

  class AccountIdDoesNotExistError < Error
    def code
      4
    end
  end

  class CutConnectionError < Error
    def code
      5
    end
  end

  class HumanActionNeededError < Error
    def code
      6
    end
  end

  class AccountIdNeededError < Error
    def code
      50
    end
  end

  class OTPNeededError < Error
    def code
      50
    end
  end
end
