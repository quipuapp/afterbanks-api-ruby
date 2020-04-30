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
      # Name changes:
      # 1. Add Particulares if there are different personal/company endpoints
      # 2. Add Empresas following the same reason
      # 3. Rename Caja Ingenieros into Caixa d'Enginyers (most known name)
      # 4. Rename Caixa Guisona into Caixa Guissona (fix typo)
      # 5. Rename Caixa burriana into Caixa Burriana (fix typo)
      # 6. Rename Bancho Pichincha into Banco Pichincha (fix typo)

      if bank_information['service'] == 'cajaingenieros'
        return "Caixa d'Enginyers"
      end

      if bank_information['service'] == 'caixaguissona'
        return "Caixa Guissona"
      end

      if bank_information['service'] == 'caixaruralburriana'
        return "Caixa Burriana"
      end

      if bank_information['service'] == 'pichincha'
        return "Banco Pichincha"
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
