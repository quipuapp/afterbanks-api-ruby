module Afterbanks
  class User < Resource
    has_fields limit: :integer,
               counter: :integer,
               remaining_calls: :integer,
               date_renewal: :date,
               detail: :string

    def self.get
      response, debug_id = Afterbanks.api_call(
        method: :post,
        path: '/me/',
        params: {
          servicekey: Afterbanks.configuration.servicekey
        }
      )

      Response.new(
        result: new(response),
        debug_id: debug_id
      )
    end
  end
end
