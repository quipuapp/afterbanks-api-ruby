module Afterbanks
  class User < Resource
    has_fields :limit, :counter, :remaining_calls, :date_renewal, :detail

    def self.get
      response = Afterbanks.api_call(
        method: :post,
        path: '/me/',
        params: {
          servicekey: Afterbanks.configuration.servicekey
        }
      )
      new(response)
    end
  end
end
