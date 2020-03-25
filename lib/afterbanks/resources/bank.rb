module Afterbanks
  class Bank < Resource
    has_fields country_code: :string,
               service: :string,
               swift: :string,
               fullname: :string,
               business: :boolean,
               documenttype: :string,
               user: :string,
               pass: :string,
               pass2: :string,
               userdesc: :string,
               passdesc: :string,
               pass2desc: :string,
               usertype: :string,
               passtype: :string,
               pass2type: :string,
               image: :string,
               color: :string

    def self.list(ordered: false)
      response = Afterbanks.api_call(
        method: :get,
        path: '/forms/'
      )

      if ordered
        response.sort! do |bank1, bank2|
          bank1['fullname'].downcase <=> bank2['fullname'].downcase
        end
      end

      Collection.new(response, self)
    end
  end
end
