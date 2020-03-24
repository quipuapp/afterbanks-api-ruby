module Afterbanks
  class Account < Resource
    has_fields product: :string,
               type: :string,
               balance: :decimal,
               currency: :string,
               description: :string,
               iban: :string,
               is_owner: :boolean,
               holders: :hash

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
        path: '/V3/',
        params: params
      )

      treat_errors_if_any(response)

      Collection.new(response, self)
    end
  end
end
