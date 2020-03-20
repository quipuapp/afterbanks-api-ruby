require "spec_helper"

describe Afterbanks::Transaction do
  describe "#list" do
    let(:service) { 'a_service' }
    let(:username) { 'a_user' }
    let(:password) { 'a_password' }
    let(:products) { 'a,b' }

    context "which returns data" do
      before do
        stub_request(:get, "https://api.afterbanks.com/V3/").
          with(
            body: {
              servicekey: 'a_servicekey_which_works',
              service: 'a_service',
              user: 'a_user',
              pass: 'a_password',
              products: 'a,b',
              startdate: '01-01-2020'
            }
          ).
          to_return(
            status: 200,
            body: response_json(resource: 'transaction', action: 'list/ok')
          )
      end

      it "works" do
        # TODO
        Afterbanks::Transaction.list(
          service: service,
          username: username,
          password: password,
          products: products
        )
      end
    end
  end
end
