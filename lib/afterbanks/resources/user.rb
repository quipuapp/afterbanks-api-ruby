module Afterbanks
  class User < Resource
    has_fields limit: :integer,
               counter: :integer,
               remaining_calls: :integer,
               date_renewal: :date,
               detail: :string

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
