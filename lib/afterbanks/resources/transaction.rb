module Afterbanks
  class Transaction < Resource
    has_fields service: :string,
               product: :string,
               date: :date,
               date2: :date,
               amount: :decimal,
               description: :string,
               balance: :decimal,
               transactionId: :string,
               categoryId: :integer

    def self.list(service:, username:, password:, password2: nil,
                  document_type: nil, products:, startdate:,
                  session_id: nil, otp: nil, counter_id: nil)

      params = {
        servicekey: Afterbanks.configuration.servicekey,
        service: service,
        user: username,
        pass: password,
        products: products,
        startdate: startdate.strftime("%d-%m-%Y")
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

      Collection.new(
        transactions_information_for(
          service: service,
          response: response,
          products: products
        ),
        self
      )
    end

    private

    def self.transactions_information_for(response:, service:, products:)
      transactions_information = []
      products_array = products.split(",")

      response.each do |account_information|
        product = account_information['product']

        if products_array.include?(product)
          transactions = account_information['transactions']
          next if transactions.nil?

          transactions.each do |transaction|
            transaction['service'] = service
            transaction['product'] = product
          end

          transactions_information += transactions
        end
      end

      transactions_information
    end
  end
end
