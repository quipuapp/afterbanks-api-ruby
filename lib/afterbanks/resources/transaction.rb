module Afterbanks
  class Transaction < Resource
    RESOURCE_PATH = '/V3/'

    has_fields :country_code, :service, :swift, :fullname, :business,
      :documenttype, :user, :pass, :pass2, :userdesc, :passdesc, :pass2desc,
      :usertype, :passtype, :pass2type, :image, :color

    def self.list(service:, username:, password:, products: nil,
                  session_id: nil, otp: nil)

      params = {
        servicekey: Afterbanks.configuration.servicekey,
        service: service,
        user: username,
        pass: password,
        products: products || 'GLOBAL', # TODO allow asking for one only
        startdate: '01-01-2020' # TODO allow asking for a specific date
      }

      params.merge!(session_id: session_id) unless session_id.nil?
      params.merge!(OTP: otp) unless otp.nil?

      response = Afterbanks.api_call(
        method: :post,
        path: RESOURCE_PATH,
        params: params
      )

      byebug

      # TODO proper error management
      if response.is_a?(Hash) && response['code'] == 50
        raise IncorrectCallParameterError.new(
          message: response['message'],
          additional_info: response['additional_info']
        )
      end

      # Collection.new(response, self) TODO use some time

      response
    end
  end
end
