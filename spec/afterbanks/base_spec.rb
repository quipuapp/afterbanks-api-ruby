require "spec_helper"

describe Afterbanks do
  describe "#configuration" do
    it "returns a Configuration instance" do
      expect(subject.configuration).to be_a(Afterbanks::Configuration)
    end
  end

  describe "#configure" do
    it "returns the servicekey properly" do
      expect(subject.configuration.servicekey).to eq('a_servicekey_which_works')
    end
  end

  describe "#api_call" do
    let(:path) { '/V3/some/endpoint' }
    let(:params) { { a: :b, c: :d, e: :f } }
    let(:api_call) {
      subject.api_call(method: method, path: path, params: params)
    }

    context "for a GET request" do
      let(:method) { :get }

      before do
        stub_request(:get, "https://api.afterbanks.com/V3/some/endpoint?a=b&c=d&e=f").
          to_return(
            status: 200,
            body: "{}",
            headers: { debug_id: 'abcd' }
          )
      end

      it "works" do
        expect(subject)
          .to receive(:log_request)
          .with(
            method: :get,
            url: "https://api.afterbanks.com/V3/some/endpoint",
            params: { a: :b, c: :d, e: :f },
            debug_id: 'abcd'
          )

        expect(RestClient::Request)
          .to receive(:execute)
          .with(
            method: :get,
            url: "https://api.afterbanks.com/V3/some/endpoint",
            headers: {
              params: { a: :b, c: :d, e: :f }
            }
          )
          .and_call_original

        api_call
      end
    end

    context "for a POST request" do
      let(:method) { :post }

      before do
        stub_request(:post, "https://api.afterbanks.com/V3/some/endpoint")
          .with(
            body: {
              "a"=>"b",
              "c"=>"d",
              "e"=>"f"
            }
          )
          .to_return(
            status: 200,
            body: "{}",
            headers: { debug_id: 'abcd' }
          )
      end

      it "works" do
        expect(subject)
          .to receive(:log_request)
          .with(
            method: :post,
            url: "https://api.afterbanks.com/V3/some/endpoint",
            params: { a: :b, c: :d, e: :f },
            debug_id: 'abcd'
          )

        expect(RestClient::Request)
          .to receive(:execute)
          .with(
            method: :post,
            url: "https://api.afterbanks.com/V3/some/endpoint",
            payload: {:a=>:b, :c=>:d, :e=>:f}
          )
          .and_call_original

        api_call
      end
    end
  end

  describe "#log_request" do
    before do
      Timecop.freeze(Time.new(2020, 3, 24, 18, 47))
    end

    let(:method) { :cuca }
    let(:url) { "https://some.where/over/the/rainbow" }
    let(:params) {
      {
        servicekey: 'secret_stuff',
        a: :z,
        user: "the_super_secret_stuff",
        pass: 'mipass',
        b: :c,
        code: 'ruby',
        pass2: 'misecondpass',
        d: :e
      }
    }
    let(:debug_id) { 'abcd' }
    let(:log_request) {
      subject.log_request(
        method: method,
        url: url,
        params: params,
        debug_id: debug_id
      )
    }

    it "works" do
      [
        "",
        "=> CUCA https://some.where/over/the/rainbow",
        "* Time: 2020-03-24 18:47:00 +0100",
        "* Timestamp: 1585072020",
        "* Debug ID: abcd",
        "* Params",
        "servicekey: <masked>",
        "a: z",
        "user: <masked>",
        "pass: <masked>",
        "b: c",
        "code: ruby",
        "pass2: <masked>",
        "d: e",
      ].each do |unique_message|
        expect(subject)
          .to receive(:log_message).with(message: unique_message).once
      end

      log_request
    end

    context "without params" do
      let(:params) { {} }

      it "works" do
        [
          "",
          "=> CUCA https://some.where/over/the/rainbow",
          "* Time: 2020-03-24 18:47:00 +0100",
          "* Timestamp: 1585072020",
          "* Debug ID: abcd",
          "* No params"
        ].each do |unique_message|
          expect(subject)
            .to receive(:log_message).with(message: unique_message).once
        end

        log_request
      end
    end

    context "without debug_id" do
      let(:debug_id) { nil }

      it "works" do
        [
          "",
          "=> CUCA https://some.where/over/the/rainbow",
          "* Time: 2020-03-24 18:47:00 +0100",
          "* Timestamp: 1585072020",
          "* Debug ID: none",
          "* Params",
          "servicekey: <masked>",
          "a: z",
          "user: <masked>",
          "pass: <masked>",
          "b: c",
          "code: ruby",
          "pass2: <masked>",
          "d: e",
        ].each do |unique_message|
          expect(subject)
            .to receive(:log_message).with(message: unique_message).once
        end

        log_request
      end
    end

    after do
      Timecop.return
    end
  end

  describe "#log_message" do
    context "without a message" do
      it "does not call the logger" do
        expect(Logger).not_to receive(:new)

        subject.log_message(message: nil)
      end
    end

    context "with a non-empty message" do
      context "with a nil Afterbanks.configuration.logger" do
        before do
          allow(Afterbanks).to receive_message_chain(:configuration, :logger) {
            nil
          }
        end

        it "does not call the logger" do
          expect_any_instance_of(Logger).not_to receive(:info)

          subject.log_message(message: "cucamonga")
        end
      end

      context "with a set-up logger" do
        before do
          logger = double(Logger)
          allow(logger).to receive(:info) { }

          allow(Afterbanks).to receive_message_chain(:configuration, :logger) {
            logger
          }
        end

        it "calls the logger properly" do
          expect(Afterbanks.configuration.logger)
            .to receive(:info).with("cucamonga").once

          subject.log_message(message: "cucamonga")
        end
      end
    end
  end
end
