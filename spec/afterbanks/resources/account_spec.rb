require "spec_helper"

describe Afterbanks::Account do
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
      shared_examples "proper request and data parsing" do
        before do
          stub_request(:post, "https://api.afterbanks.com/V3/").
            with(body: body).
            to_return(
              status: 200,
              body: response_json(resource: 'account', action: 'list'),
              headers: { debug_id: 'acclist1234' }
            )
        end

        it "does the proper request and returns the proper Afterbanks::Account instances" do
          response = api_call

          expect(response.class).to eq(Afterbanks::Response)
          expect(response.debug_id).to eq('acclist1234')

          accounts = response.result

          expect(accounts.class).to eq(Afterbanks::Collection)
          expect(accounts.size).to eq(3)

          account1, account2, account3 = accounts

          expect(account1.class).to eq(Afterbanks::Account)
          expect(account1.service).to eq("a_service")
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
          expect(account2.service).to eq("a_service")
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
          expect(account3.service).to eq("a_service")
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

        include_examples "proper request and data parsing"
      end

      context "for a case with a document type" do
        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "pass2" => "cucamonga",
            "documentType" => "1",
            "products" => 'GLOBAL'
          }
        }
        let(:api_call) {
          Afterbanks::Account.list(
            service: service,
            username: username,
            password: password,
            password2: 'cucamonga',
            document_type: 1
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

        include_examples "proper request and data parsing"
      end

      context "for a case when we have to avoid caching" do
        before do
          Timecop.freeze(2019, 12, 3, 17, 22)
        end

        let(:body) {
          {
            "servicekey" => 'a_servicekey_which_works',
            "service" => service,
            "user" => username,
            "pass" => password,
            "products" => 'GLOBAL',
            "randomizer" => '1575390120'
          }
        }

        let(:api_call) {
          Afterbanks::Account.list(
            service: service,
            username: username,
            password: password,
            avoid_caching: true
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
              body: response_json(resource: 'common', action: 'error_1'),
              headers: { debug_id: 'debugerror1' }
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
              body: response_json(resource: 'common', action: 'error_2'),
              headers: { debug_id: 'debugerror2' }
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
              body: response_json(resource: 'common', action: 'error_3'),
              headers: { debug_id: 'debugerror3' }
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
              body: response_json(resource: 'common', action: 'error_4'),
              headers: { debug_id: 'debugerror4' }
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
              body: response_json(resource: 'common', action: 'error_5'),
              headers: { debug_id: 'debugerror5' }
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
              body: response_json(resource: 'common', action: 'error_6'),
              headers: { debug_id: 'debugerror6' }
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
                body: response_json(resource: 'common', action: 'error_50_two_way_authentication'),
                headers: { debug_id: 'debugerror50tsa' }
              )
          end

          it "raises an TwoStepAuthenticationError" do
            expect { api_call }.to raise_error(
              an_instance_of(Afterbanks::TwoStepAuthenticationError)
                .and having_attributes(
                  code: 50,
                  message: "A bank te ha enviado un código",
                  debug_id: 'debugerror50tsa',
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
                body: response_json(resource: 'common', action: 'error_50_account_id'),
                headers: { debug_id: 'debugerror50accid' }
              )
          end

          it "raises an AccountIdNeededError" do
            expect { api_call }.to raise_error(
              an_instance_of(Afterbanks::AccountIdNeededError)
                .and having_attributes(
                  code: 50,
                  message: "Escoge una cuenta",
                  debug_id: 'debugerror50accid',
                  additional_info: [
                    {
                      "account_id" => 0,
                      "description" => "Account one"
                    }, {
                      "account_id" => 1,
                      "description" => "Account two"
                    }
                  ]
                )
            )
          end
        end

        context "which is another one" do
          before do
            stub_request(:post, "https://api.afterbanks.com/V3/").
              with(body: body).
              to_return(
                status: 200,
                body: response_json(resource: 'common', action: 'error_50_missing_parameter'),
                headers: { debug_id: 'debugerror50missparam' }
              )
          end

          it "raises an MissingParameterError" do
            expect { api_call }.to raise_error(
              an_instance_of(Afterbanks::MissingParameterError)
                .and having_attributes(
                  code: 50,
                  message: "Falta el servicekey",
                  debug_id: 'debugerror50missparam'
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
    let(:type) { 'checking' }
    let(:balance) { 1094.12 }
    let(:currency) { 'EUR' }
    let(:description) { 'A checking account' }
    let(:iban) { 'ES2720809591124344566256' }
    let(:is_owner) { true }
    let(:holders) {
      [
        {
          "role": "Admin",
          "name": "Mary",
          "id": 1
        },
        {
          "role": "Admin",
          "name": "Liz",
          "id": 2
        },
        {
          "role": "Supervisor",
          "name": "John",
          "id": 3
        }
      ]
    }
    let(:original_account) do
      Afterbanks::Account.new(
        service: service,
        product: product,
        type: type,
        balance: balance,
        currency: currency,
        description: description,
        iban: iban,
        is_owner: is_owner,
        holders: holders
      )
    end

    it "works" do
      serialized_account = Marshal.dump(original_account)
      recovered_account = Marshal.load(serialized_account)

      expect(recovered_account.class).to eq(Afterbanks::Account)
      expect(recovered_account.service).to eq(service)
      expect(recovered_account.product).to eq(product)
      expect(recovered_account.type).to eq(type)
      expect(recovered_account.balance).to eq(balance)
      expect(recovered_account.currency).to eq(currency)
      expect(recovered_account.description).to eq(description)
      expect(recovered_account.iban).to eq(iban)
      expect(recovered_account.is_owner).to eq(is_owner)
      expect(recovered_account.holders).to eq(holders)
    end
  end
end
