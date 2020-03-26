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

    def self.list(service:, username:, password:, password2: nil,
                  document_type: nil, session_id: nil, otp: nil, counter_id: nil)

      params = {
        servicekey: Afterbanks.configuration.servicekey,
        service: service,
        user: username,
        pass: password,
        products: 'GLOBAL'
      }

      params.merge!(pass2: password2) unless password2.nil?
      params.merge!(documentType: document_type) unless document_type.nil?
      params.merge!(session_id: session_id) unless session_id.nil?
      params.merge!(OTP: otp) unless otp.nil?
      params.merge!(counterId: counter_id) unless counter_id.nil?

      response = Afterbanks.api_call(
        method: :post,
        path: '/V3/',
        params: params
      )

      Collection.new(response, self)
    end
  end
end
