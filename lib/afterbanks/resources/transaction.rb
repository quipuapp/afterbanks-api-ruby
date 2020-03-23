module Afterbanks
  class Transaction < Resource
    RESOURCE_PATH = '/V3/'

    has_fields :country_code, :service, :swift, :fullname, :business,
      :documenttype, :user, :pass, :pass2, :userdesc, :passdesc, :pass2desc,
      :usertype, :passtype, :pass2type, :image, :color

    def self.list(service:, username:, password:, products:,
                  session_id: nil, otp: nil, counter_id: nil,
                  force_refresh: false)

      params = {
        servicekey: Afterbanks.configuration.servicekey,
        service: service,
        user: username,
        pass: password,
        products: products,
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

      treat_errors_if_any(response)

      response # TODO format properly
    end
  end
end
