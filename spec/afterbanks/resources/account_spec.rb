require "spec_helper"

describe Afterbanks::Account do
  describe "#list" do
    let(:service) { 'a_service' }
    let(:username) { 'a_user' }
    let(:password) { 'a_password' }

    context "which returns data" do
      before do
        stub_request(:post, "https://api.afterbanks.com/V3/").
          with(
            body: {
              servicekey: 'a_servicekey_which_works',
              service: 'a_service',
              user: 'a_user',
              pass: 'a_password',
              products: 'GLOBAL',
              startdate: '01-01-2020'
            }
          ).
          to_return(
            status: 200,
            body: response_json(resource: 'account', action: 'list/ok')
          )
      end

      it "works" do
        accounts = Afterbanks::Account.list(
          service: service,
          username: username,
          password: password
        )

        expect(accounts.class).to eq(Afterbanks::Collection)
        expect(accounts.size).to eq(3)

        account1, account2, account3 = accounts

        expect(account1.product).to eq("ES2720809591124344566256")
        expect(account1.type).to eq("checking")
        expect(account1.balance).to eq(104.33)
        expect(account1.currency).to eq("EUR")
        expect(account1.description).to eq("A checking account")
        expect(account1.iban).to eq("ES2720809591124344566256")
        expect(account1.is_owner).to eq(1)
        expect(account1.holders).to eq(
          [
            { "role" => 'Admin', "name" => 'Mary', "id" => 1 },
            { "role" => 'Admin', "name" => 'Liz', "id" => 2 },
            { "role" => 'Supervisor', "name" => 'John', "id" => 3 }
          ]
        )

        expect(account2.product).to eq("ES8401821618664757634169")
        expect(account2.type).to eq("checking")
        expect(account2.balance).to eq(216.19)
        expect(account2.currency).to eq("EUR")
        expect(account2.description).to eq("Another checking account")
        expect(account2.iban).to eq("ES8401821618664757634169")
        expect(account2.is_owner).to eq(1)
        expect(account2.holders).to eq(
          [
            { "role" => 'Admin', "name" => 'Mary', "id" => 11 }
          ]
        )

        expect(account3.product).to eq("ES9231902434113168967688")
        expect(account3.type).to eq("loan")
        expect(account3.balance).to eq(-91.99)
        expect(account3.currency).to eq("USD")
        expect(account3.description).to eq("A loan")
        expect(account3.iban).to eq("ES9231902434113168967688")
        expect(account3.is_owner).to eq(0)
        expect(account3.holders).to eq(
          [
            { "role" => 'Admin', "name" => 'Sandy', "id" => 12 },
            { "role" => 'Supervisor', "name" => 'Joe', "id" => 34 }
          ]
        )
      end
    end
  end
end
