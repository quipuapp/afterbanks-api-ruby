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

      begin
        response = RestClient::Request.execute(request_params)

        log_request(
          method: method,
          url: url,
          params: params,
          debug_id: response.headers[:debug_id]
        )

        JSON.parse(response)
      rescue RestClient::BadRequest => bad_request
        log_request(
          method: method,
          url: url,
          params: params
        )

        raise bad_request
      end
    end

    def log_request(method:, url:, params: {}, debug_id: nil)
      log_message("")
      log_message("=> #{method.upcase} #{url}")

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
  end
end
