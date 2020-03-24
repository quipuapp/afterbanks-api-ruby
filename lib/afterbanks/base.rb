require 'rest-client'
require 'json'

module Afterbanks
  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def api_call(method:, path:, params: {})
      url = 'https://api.afterbanks.com' + path

      request_params = { method: method, url: url }

      if method == :post
        request_params.merge!(payload: params)
      else
        request_params.merge!(headers: { params: params })
      end

      response = begin
        RestClient::Request.execute(request_params)
      rescue RestClient::BadRequest, RestClient::ExpectationFailed => bad_request
        bad_request.response
      end

      log_request(
        method: method,
        url: url,
        params: params,
        debug_id: response.headers[:debug_id]
      )

      response_body = JSON.parse(response.body)

      treat_errors_if_any(response_body)

      response_body
    end

    def log_request(method:, url:, params: {}, debug_id: nil)
      now = Time.now

      log_message("")
      log_message("=> #{method.upcase} #{url}")

      log_message("* Time: #{now}")
      log_message("* Timestamp: #{now.to_i}")
      log_message("* Debug ID: #{debug_id || 'none'}")

      if params.any?
        log_message("* Params")
        params.each do |key, value|
          safe_value = if %w{servicekey user pass pass2}.include?(key.to_s)
                         "<masked>"
                       else
                         value
                       end

          log_message("#{key}: #{safe_value}")
        end
      else
        log_message("* No params")
      end
    end

    def log_message(message)
      return if message.nil?

      logger = Afterbanks.configuration.logger
      return if logger.nil?

      logger.info(message)
    end

    private

    def treat_errors_if_any(response_body)
      return unless response_body.is_a?(Hash)

      code = response_body['code']
      message = response_body['message']
      additional_info = response_body['additional_info']

      case code
      when 1
        raise GenericError.new(message: message)
      when 2
        raise ServiceUnavailableTemporarilyError.new(message: message)
      when 3
        raise ConnectionDataError.new(message: message)
      when 4
        raise AccountIdDoesNotExistError.new(message: message)
      when 5
        raise CutConnectionError.new(message: message)
      when 6
        raise HumanActionNeededError.new(message: message)
      when 50
        if additional_info && additional_info['session_id']
          raise OTPNeededError.new(
            message: message,
            additional_info: additional_info
          )
        end

        raise AccountIdNeededError.new(message: message)
      end

      nil
    end
  end
end
