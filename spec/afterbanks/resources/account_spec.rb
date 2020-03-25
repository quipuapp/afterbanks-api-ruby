require "spec_helper"

describe Afterbanks::Account do
  shared_examples "proper request and data parsing" do
    it "does the proper request and returns the proper Afterbanks::Account instances" do
      accounts = api_call

      expect(accounts.class).to eq(Afterbanks::Collection)
      expect(accounts.size).to eq(3)

      account1, account2, account3 = accounts

      expect(account1.class).to eq(Afterbanks::Account)
      expect(account1.product).to eq("ES2720809591124344566256")
      expect(account1.type).to eq("checking")
      expect(account1.balance).to eq(1094.12)
      expect(account1.currency).to eq("EUR")
      expect(account1.description).to eq("A checking account")
      expect(account1.iban).to eq("ES2720809591124344566256")
      expect(account1.is_owner).to be_truthy
      expect(account1.holders).to eq(
        [
          { "role" => 'Admin', "name" => 'Mary', "id" => 1 },
          { "role" => 'Admin', "name" => 'Liz', "id" => 2 },
          { "role" => 'Supervisor', "name" => 'John', "id" => 3 }
        ]
      )

      expect(account2.class).to eq(Afterbanks::Account)
      expect(account2.product).to eq("ES8401821618664757634169")
      expect(account2.type).to eq("checking")
      expect(account2.balance).to eq(216.19)
      expect(account2.currency).to eq("EUR")
      expect(account2.description).to eq("Another checking account")
      expect(account2.iban).to eq("ES8401821618664757634169")
      expect(account2.is_owner).to be_truthy
      expect(account2.holders).to eq(
        [
          { "role" => 'Admin', "name" => 'Mary', "id" => 11 }
        ]
      )

      expect(account3.class).to eq(Afterbanks::Account)
      expect(account3.product).to eq("ES9231902434113168967688")
      expect(account3.type).to eq("loan")
      expect(account3.balance).to eq(-91.99)
      expect(account3.currency).to eq("USD")
      expect(account3.description).to eq("A loan")
      expect(account3.iban).to eq("ES9231902434113168967688")
      expect(account3.is_owner).to be_falsey
      expect(account3.holders).to eq(
        [
          { "role" => 'Admin', "name" => 'Sandy', "id" => 12 },
          { "role" => 'Supervisor', "name" => 'Joe', "id" => 34 }
        ]
      )
    end
  end

  describe "#list" do
    let(:service) { 'a_service' }
    let(:username) { 'a_user' }
    let(:password) { 'a_password' }
    let(:body) {
      {
        "servicekey" => 'a_servicekey_which_works',
        "service" => service,
        "user" => username,
        "pass" => password,
        "products" => 'GLOBAL'
      }
    }
    let(:api_call) {
      Afterbanks::Account.list(
        service: service,
        username: username,
        password: password
      )
    }

    context "when returning data" do
      context "for a normal case" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'account', action: 'list')
            )
        end

        include_examples "proper request and data parsing"
      end

      context "for a case with a second password" do
        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "pass2" => "cucamonga",
            "products" => 'GLOBAL'
          }
        }
        let(:api_call) {
          Afterbanks::Account.list(
            service: service,
            username: username,
            password: password,
            password2: 'cucamonga'
          )
        }

        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'account', action: 'list')
            )
        end

        include_examples "proper request and data parsing"
      end

      context "for an OTP case" do
        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "products" => 'GLOBAL',
            "session_id" => 'abcd1234',
            "OTP" => '1745',
            "counterId" => "4"
          }
        }
        let(:api_call) {
          Afterbanks::Account.list(
            service: service,
            username: username,
            password: password,
            session_id: 'abcd1234',
            otp: '1745',
            counter_id: 4
          )
        }

        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'account', action: 'list')
            )
        end

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
