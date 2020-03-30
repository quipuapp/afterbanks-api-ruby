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

      Collection.new(
        banks_information_for(
          response: response
        ),
        self
      )
    end

    private

    def self.banks_information_for(response:)
      banks_information = []

      response.each do |bank_information|
        if bank_information['business'] == "1"
          bank_information['fullname'] += " Empresas"
        end

        banks_information << bank_information
      end

      banks_information
    end
  end
end
