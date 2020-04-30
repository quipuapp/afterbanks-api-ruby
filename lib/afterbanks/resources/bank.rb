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
      response, debug_id = Afterbanks.api_call(
        method: :get,
        path: '/forms/'
      )

      Response.new(
        result: Collection.new(
          banks_information_for(
            response: response,
            ordered: ordered
          ),
          self
        ),
        debug_id: debug_id
      )
    end

    private

    def self.banks_information_for(response:, ordered:)
      banks_information = []

      services_number_by_bank_id = {}
      response.each { |bank_information|
        bank_id = bank_id_for(bank_information: bank_information)
        services_number_by_bank_id[bank_id] ||= 0
        services_number_by_bank_id[bank_id] += 1
      }

      response.each do |bank_information|
        bank_information['fullname'] = bank_name_for(
          bank_information: bank_information,
          services_number_by_bank_id: services_number_by_bank_id
        )

        banks_information << bank_information
      end

      if ordered
        banks_information.sort! do |bank_information1, bank_information2|
          bank_information1['fullname'].downcase <=> bank_information2['fullname'].downcase
        end
      end

      banks_information
    end

    def self.bank_name_for(bank_information:, services_number_by_bank_id:)
      if bank_information['service'] == 'cajaingenieros'
        return "Caixa d'Enginyers"
      end

      fullname = bank_information['fullname']
      if bank_information['business'] == "1"
        return "#{fullname} Empresas"
      end

      bank_id = bank_id_for(bank_information: bank_information)
      if services_number_by_bank_id[bank_id] > 1
        return "#{fullname} Particulares"
      end

      fullname
    end

    def self.bank_id_for(bank_information:)
      bank_information['service'].split("_").first
    end
  end
end
