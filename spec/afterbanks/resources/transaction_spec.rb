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
      before do
        stub_request(:post, "https://api.afterbanks.com/V3/").
          with(body: body).
          to_return(
            status: 200,
            body: response_json(resource: 'transaction', action: 'list')
          )
      end

      it "works" do
        transactions = api_call

        expect(transactions.class).to eq(Afterbanks::Collection)
        expect(transactions.size).to eq(4)

        transaction1, transaction2, transaction3, transaction4 = transactions

        expect(transaction1.class).to eq(Afterbanks::Transaction)
        expect(transaction1.product).to eq('ES2720809591124344566256')
        expect(transaction1.date).to eq(Date.new(2020, 2, 1))
        expect(transaction1.date2).to eq(Date.new(2020, 2, 2))
        expect(transaction1.amount).to eq(123.11)
        expect(transaction1.description).to eq("Some money in")
        expect(transaction1.balance).to eq(1094.12)
        expect(transaction1.transactionId).to eq("abcd1234")
        expect(transaction1.categoryId).to eq(19)

        expect(transaction2.class).to eq(Afterbanks::Transaction)
        expect(transaction2.product).to eq('ES2720809591124344566256')
        expect(transaction2.date).to eq(Date.new(2020, 1, 20))
        expect(transaction2.date2).to eq(Date.new(2020, 1, 20))
        expect(transaction2.amount).to eq(-29.58)
        expect(transaction2.description).to eq("A small purchase")
        expect(transaction2.balance).to eq(971.01)
        expect(transaction2.transactionId).to eq("defg4321")
        expect(transaction2.categoryId).to eq(6)

        expect(transaction3.class).to eq(Afterbanks::Transaction)
        expect(transaction3.product).to eq('ES2720809591124344566256')
        expect(transaction3.date).to eq(Date.new(2020, 1, 15))
        expect(transaction3.date2).to eq(Date.new(2020, 1, 15))
        expect(transaction3.amount).to eq(-467.12)
        expect(transaction3.description).to eq("A big purchase")
        expect(transaction3.balance).to eq(1000.59)
        expect(transaction3.transactionId).to eq("ghij1928")
        expect(transaction3.categoryId).to eq(12)

        expect(transaction4.class).to eq(Afterbanks::Transaction)
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

    context "when returning an error" do
      context "which is generic (code 1)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_1')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::GenericError)
              .and having_attributes(
                message: "Error genérico"
              )
          )
        end
      end

      context "which is generic (code 2)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_2')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::ServiceUnavailableTemporarilyError)
              .and having_attributes(
                message: "Servicio no disponible ahora mismo"
              )
          )
        end
      end

      context "which is generic (code 3)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_3')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::ConnectionDataError)
              .and having_attributes(
                message: "Datos de la conexión inválidos"
              )
          )
        end
      end

      context "which is generic (code 4)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_4')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::AccountIdDoesNotExistError)
              .and having_attributes(
                message: "AccountID no existe"
              )
          )
        end
      end

      context "which is generic (code 5)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_5')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::CutConnectionError)
              .and having_attributes(
                message: "Conexión cortada"
              )
          )
        end
      end

      context "which is generic (code 6)" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'common', action: 'error_6')
            )
        end

        it "raises a GenericError" do
          expect { api_call }.to raise_error(
            an_instance_of(Afterbanks::HumanActionNeededError)
              .and having_attributes(
                message: "El usuario debe realizar una acción en el banco"
              )
          )
        end
      end

      context "which needs for another parameter (code 50)" do
        context "which is OTP" do
          before do
            stub_request(:post, "https://api.afterbanks.com/V3/").
              with(body: body).
              to_return(
                status: 200,
                body: response_json(resource: 'common', action: 'error_50_otp')
              )
          end

          it "raises an OTPNeededError" do
            expect { api_call }.to raise_error(
              an_instance_of(Afterbanks::OTPNeededError)
                .and having_attributes(
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
                  message: "No se han encontrado productos"
                )
            )
          end
        end
      end
    end
  end
end
