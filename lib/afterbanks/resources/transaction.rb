module Afterbanks
  class Transaction < Resource
    RESOURCE_PATH = '/V3/'

    has_fields :product, :date, :date2, :amount, :description, :balance,
      :transactionId, :categoryId

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

      Collection.new(transactions_information_for(response, products), self)
    end

    private

    def self.transactions_information_for(response, products)
      transactions_information = []
      products_array = products.split(",")

      response.each do |account_information|
        product = account_information['product']

        if products_array.include?(product)
          transactions = account_information['transactions']

          transactions.each do |transaction|
            transaction['product'] = product
          end

          transactions_information += transactions
        end
      end

      transactions_information
    end
  end
end
