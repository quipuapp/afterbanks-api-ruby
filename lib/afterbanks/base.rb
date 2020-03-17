require 'rest-client'
require 'json'

module Afterbanks
  BASE_URL = 'https://api.afterbanks.com'
  SENSIBLE_PARAMS = %w{user pass pass2}

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def api_call(method:, path:, params: {})
      url = Afterbanks.const_get(:BASE_URL) + path

      log_request(method, url, params)

      request_params = { method: method, url: url }

      if method == :post
        request_params.merge!(payload: params)
      else
        request_params.merge!(headers: { params: params })
      end

      begin
        response = RestClient::Request.execute(request_params)
        p response

        JSON.parse(response)
      rescue StandardError => error
        # TODO handle properly
        response = JSON.parse(error.response)
        raise Error.new(response['error'])
      end
    end

    def log_request(method, url, params)
      log_message("")
      log_message("=> #{method.upcase} #{url}")

      if params.any?
        log_message("* Params")
        params.each do |key, value|
          safe_value = if SENSIBLE_PARAMS.include?(key.to_s)
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
  end
end
