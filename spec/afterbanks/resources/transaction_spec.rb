require "spec_helper"

describe Afterbanks::Bank do
  before { configure_afterbanks }

  describe "#list" do
    let(:service) { 'a_service' }
    let(:username) { 'user' }
    let(:password) { 'password' }

    context "which returns data" do
      before do
        stub_request(:get, "https://api.afterbanks.com/V3/").
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
            body: response_json(resource: 'transaction', action: 'list/ok')
          )
      end

      it "works" do
        # TODO
        Afterbanks::Transaction.list(
          service: service,
          username: username,
          password: password
        )
      end
    end

    context "which challenges for a code" do
      it "raises an error with the proper information" do
        # TODO
        Afterbanks::Transaction.list(
          service: service,
          username: username,
          password: password
        )
      end
    end
  end
end
