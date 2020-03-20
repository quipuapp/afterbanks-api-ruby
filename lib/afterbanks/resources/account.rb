module Afterbanks
  class Account < Resource
    RESOURCE_PATH = '/V3/'

    has_fields :product, :type, :balance, :currency, :description, :iban,
      :is_owner, :holders

    def self.list(service:, username:, password:,
                  session_id: nil, otp: nil, counter_id: nil,
                  force_refresh: false)

      params = {
        servicekey: Afterbanks.configuration.servicekey,
        service: service,
        user: username,
        pass: password,
        products: 'GLOBAL',
        startdate: '01-01-2020' # TODO allow asking for a specific date
      }

      params.merge!(session_id: session_id) unless session_id.nil?
      params.merge!(OTP: otp) unless otp.nil?
      params.merge!(counterId: counter_id) unless counter_id.nil?
      params.merge!(forze_refresh: 1) if force_refresh # The z is not a typo

      response = Afterbanks.api_call(
        method: :post,
        path: RESOURCE_PATH,
        params: params
      )

      # TODO proper error management
      if response.is_a?(Hash) && response['code'] == 50
        raise IncorrectCallParameterError.new(
          message: response['message'],
          additional_info: response['additional_info']
        )
      end

      Collection.new(response, self)
    end
  end
end
