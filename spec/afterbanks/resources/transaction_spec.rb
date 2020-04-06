require "spec_helper"

describe Afterbanks::Transaction do
  describe "#list" do
    let(:service) { 'a_service' }
    let(:username) { 'a_user' }
    let(:password) { 'a_password' }
    let(:products) { 'ES2720809591124344566256' }
    let(:startdate) { Date.new(2020, 3, 24) }
    let(:body) {
      {
        "servicekey" => 'a_servicekey_which_works',
        "service" => service,
        "user" => username,
        "pass" => password,
        "products" => products,
        "startdate" => startdate.strftime("%d-%m-%Y")
      }
    }
    let(:api_call) {
      Afterbanks::Transaction.list(
        service: service,
        username: username,
        password: password,
        products: products,
        startdate: startdate
      )
    }

    context "when returning data" do
      shared_examples "proper request and data parsing" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'transaction', action: 'list')
            )
        end

        it "does the proper request and returns the proper Afterbanks::Transaction instances" do
          transactions = api_call

          expect(transactions.class).to eq(Afterbanks::Collection)
          expect(transactions.size).to eq(4)

          transaction1, transaction2, transaction3, transaction4 = transactions

          expect(transaction1.class).to eq(Afterbanks::Transaction)
          expect(transaction1.service).to eq('a_service')
          expect(transaction1.product).to eq('ES2720809591124344566256')
          expect(transaction1.date).to eq(Date.new(2020, 2, 1))
          expect(transaction1.date2).to eq(Date.new(2020, 2, 2))
          expect(transaction1.amount).to eq(123.11)
          expect(transaction1.description).to eq("Some money in")
          expect(transaction1.balance).to eq(1094.12)
          expect(transaction1.transactionId).to eq("abcd1234")
          expect(transaction1.categoryId).to eq(19)

          expect(transaction2.class).to eq(Afterbanks::Transaction)
          expect(transaction2.service).to eq('a_service')
          expect(transaction2.product).to eq('ES2720809591124344566256')
          expect(transaction2.date).to eq(Date.new(2020, 1, 20))
          expect(transaction2.date2).to eq(Date.new(2020, 1, 20))
          expect(transaction2.amount).to eq(-29.58)
          expect(transaction2.description).to eq("A small purchase")
          expect(transaction2.balance).to eq(971.01)
          expect(transaction2.transactionId).to eq("defg4321")
          expect(transaction2.categoryId).to eq(6)

          expect(transaction3.class).to eq(Afterbanks::Transaction)
          expect(transaction3.service).to eq('a_service')
          expect(transaction3.product).to eq('ES2720809591124344566256')
          expect(transaction3.date).to eq(Date.new(2020, 1, 15))
          expect(transaction3.date2).to eq(Date.new(2020, 1, 15))
          expect(transaction3.amount).to eq(-467.12)
          expect(transaction3.description).to eq("A big purchase")
          expect(transaction3.balance).to eq(1000.59)
          expect(transaction3.transactionId).to eq("ghij1928")
          expect(transaction3.categoryId).to eq(12)

          expect(transaction4.class).to eq(Afterbanks::Transaction)
          expect(transaction4.service).to eq('a_service')
          expect(transaction4.product).to eq('ES2720809591124344566256')
          expect(transaction4.date).to eq(Date.new(2019, 1, 1))
          expect(transaction4.date2).to eq(Date.new(2019, 1, 1))
          expect(transaction4.amount).to eq(1467.71)
          expect(transaction4.description).to eq("Initial transaction")
          expect(transaction4.balance).to eq(1467.71)
          expect(transaction4.transactionId).to eq("jklm5647")
          expect(transaction4.categoryId).to eq(3)
        end
      end

      context "for a normal case" do
        include_examples "proper request and data parsing"
      end

      context "for a case with a second password" do
        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "pass2" => 'cucamonga',
            "products" => products,
            "startdate" => startdate.strftime("%d-%m-%Y")
          }
        }
        let(:api_call) {
          Afterbanks::Transaction.list(
            service: service,
            username: username,
            password: password,
            password2: "cucamonga",
            products: products,
            startdate: startdate
          )
        }

        include_examples "proper request and data parsing"
      end

      context "for a case with a document type" do
        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "pass2" => 'cucamonga',
            "documentType" => "1",
            "products" => products,
            "startdate" => startdate.strftime("%d-%m-%Y")
          }
        }
        let(:api_call) {
          Afterbanks::Transaction.list(
            service: service,
            username: username,
            password: password,
            password2: "cucamonga",
            document_type: 1,
            products: products,
            startdate: startdate
          )
        }

        include_examples "proper request and data parsing"
      end

      context "for a two step authentication case" do
        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "products" => products,
            "startdate" => startdate.strftime("%d-%m-%Y"),
            "session_id" => 'abcd1234',
            "OTP" => '1745',
            "counterId" => "4"
          }
        }
        let(:api_call) {
          Afterbanks::Transaction.list(
            service: service,
            username: username,
            password: password,
            products: products,
            startdate: startdate,
            session_id: 'abcd1234',
            otp: '1745',
            counter_id: 4
          )
        }

        include_examples "proper request and data parsing"
      end
    end

    context "when returning an error" do
      context "which is generic (code 1)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 400,
              body: response_json(resource: 'common', action: 'error_1')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::GenericError)
              .and having_attributes(
                code: 1,
                message: "Error genérico"
              )
          )
        end
      end

      context "which is service unavailable temporarily (code 2)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_2')
            )
        end

        it "raises a ServiceUnavailableTemporarilyError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::ServiceUnavailableTemporarilyError)
              .and having_attributes(
                code: 2,
                message: "Servicio no disponible ahora mismo"
              )
          )
        end
      end

      context "which is connection data (code 3)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 417,
              body: response_json(resource: 'common', action: 'error_3')
            )
        end

        it "raises a ConnectionDataError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::ConnectionDataError)
              .and having_attributes(
                code: 3,
                message: "Datos de la conexión inválidos"
              )
          )
        end
      end

      context "which is account ID does not exist (code 4)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_4')
            )
        end

        it "raises a AccountIdDoesNotExistError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::AccountIdDoesNotExistError)
              .and having_attributes(
                code: 4,
                message: "AccountID no existe"
              )
          )
        end
      end

      context "which is cut connection (code 5)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_5')
            )
        end

        it "raises a CutConnectionError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::CutConnectionError)
              .and having_attributes(
                code: 5,
                message: "Conexión cortada"
              )
          )
        end
      end

      context "which is human action needed (code 6)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_6')
            )
        end

        it "raises a HumanActionNeededError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::HumanActionNeededError)
              .and having_attributes(
                code: 6,
                message: "El usuario debe realizar una acción en el banco"
              )
          )
        end
      end

      context "which needs for another parameter (code 50)" do
        context "which is two step authentication" do
          before do
            stub_request(:post, "https://api.afterbanks.com/V3/").
              with(body: body).
              to_return(
                status: 200,
                body: response_json(resource: 'common', action: 'error_50_otp')
              )
          end

          it "raises an TwoStepAuthenticationError" do
            expect { api_call }.to raise_error(
              an_instance_of(Afterbanks::TwoStepAuthenticationError)
                .and having_attributes(
                  code: 50,
                  message: "A bank te ha enviado un código",
                  additional_info: {
                    "session_id" => "12345678",
                    "counterId" => 4
                  }
                )
            )
          end
        end

        context "which is the account ID" do
          before do
            stub_request(:post, "https://api.afterbanks.com/V3/").
              with(body: body).
              to_return(
                status: 200,
                body: response_json(resource: 'common', action: 'error_50_account_id')
              )
          end

          it "raises an AccountIdNeededError" do
            expect { api_call }.to raise_error(
              an_instance_of(Afterbanks::AccountIdNeededError)
                .and having_attributes(
                  code: 50,
                  message: "No se han encontrado productos"
                )
            )
          end
        end
      end
    end
  end

  describe "serialization" do
    let(:service) { 'bbva' }
    let(:product) { 'ES2720809591124344566256' }
    let(:date) { Date.new(2020, 3, 16) }
    let(:date2) { Date.new(2020, 4, 13) }
    let(:amount) { -12.49 }
    let(:description) { "A handful of stuff" }
    let(:balance) { 412.62 }
    let(:transactionId) { '123454321NZ' }
    let(:categoryId) { 13 }
    let(:original_transaction) do
      Afterbanks::Transaction.new(
        service: service,
        product: product,
        date: date,
        date2: date2,
        amount: amount,
        description: description,
        balance: balance,
        transactionId: transactionId,
        categoryId: categoryId
      )
    end

    it "works" do
      serialized_transaction = Marshal.dump(original_transaction)
      recovered_transaction = Marshal.load(serialized_transaction)

      expect(recovered_transaction.class).to eq(Afterbanks::Transaction)
      expect(recovered_transaction.service).to eq(service)
      expect(recovered_transaction.product).to eq(product)
      expect(recovered_transaction.date).to eq(date)
      expect(recovered_transaction.date2).to eq(date2)
      expect(recovered_transaction.amount).to eq(amount)
      expect(recovered_transaction.description).to eq(description)
      expect(recovered_transaction.balance).to eq(balance)
      expect(recovered_transaction.transactionId).to eq(transactionId)
      expect(recovered_transaction.categoryId).to eq(categoryId)
    end
  end
end
