require "spec_helper"

describe Afterbanks::User do
  describe "#get" do
    before do
      stub_request(:post, "https://api.afterbanks.com/me/").
        with(
          body: {
            servicekey: 'a_servicekey_which_works'
          }
        ).
        to_return(
          status: 200,
          body: response_json(resource: 'user', action: 'get')
        )
    end

    it "works" do
      user = Afterbanks::User.get

      expect(user.class).to eq(Afterbanks::User)
      expect(user.limit).to eq(1234391245)
      expect(user.counter).to eq(912)
      expect(user.remaining_calls).to eq(1234390333)
      expect(user.date_renewal).to eq(Date.new(2020, 4, 1))
      expect(user.detail).to be_nil
    end
  end
end
