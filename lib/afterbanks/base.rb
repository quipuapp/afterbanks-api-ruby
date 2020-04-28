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

      debug_id = response.headers[:debug_id]

      log_request(
        method: method,
        url: url,
        params: params,
        debug_id: debug_id
      )

      response_body = JSON.parse(response.body)

      treat_errors_if_any(
        response_body: response_body,
        debug_id: debug_id
      )

      [response_body, debug_id]
    end

    def log_request(method:, url:, params: {}, debug_id: nil)
      now = Time.now

      log_message(message: "")
      log_message(message: "=> #{method.upcase} #{url}")

      log_message(message: "* Time: #{now}")
      log_message(message: "* Timestamp: #{now.to_i}")
      log_message(message: "* Debug ID: #{debug_id || 'none'}")

      if params.any?
        log_message(message: "* Params")
        params.each do |key, value|
          safe_value = if %w{servicekey user pass pass2}.include?(key.to_s)
                         "<masked>"
                       else
                         value
                       end

          log_message(message: "#{key}: #{safe_value}")
        end
      else
        log_message(message: "* No params")
      end
    end

    def log_message(message: nil)
      return if message.nil?

      logger = Afterbanks.configuration.logger
      return if logger.nil?

      logger.info(message)
    end

    private

    def treat_errors_if_any(response_body:, debug_id:)
      return unless response_body.is_a?(Hash)

      code = response_body['code']
      message = response_body['message']
      additional_info = response_body['additional_info']

      error_info = { message: message, debug_id: debug_id }

      case code
      when 1
        raise GenericError.new(error_info)
      when 2
        raise ServiceUnavailableTemporarilyError.new(error_info)
      when 3
        raise ConnectionDataError.new(error_info)
      when 4
        raise AccountIdDoesNotExistError.new(error_info)
      when 5
        raise CutConnectionError.new(error_info)
      when 6
        raise HumanActionNeededError.new(error_info)
      when 50
        unless additional_info
          raise MissingParameterError.new(error_info)
        end

        error_info.merge!(additional_info: additional_info)

        if additional_info['session_id']
          raise TwoStepAuthenticationError.new(error_info)
        else
          raise AccountIdNeededError.new(error_info)
        end
      end

      nil
    end
  end
end
