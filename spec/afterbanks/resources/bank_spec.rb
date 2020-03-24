require "spec_helper"

describe Afterbanks::Bank do
  describe "#list" do
    before do
      stub_request(:get, "https://api.afterbanks.com/forms/").
        to_return(
          status: 200,
          body: response_json(resource: 'bank', action: 'list')
        )
    end

    it "works" do
      banks = Afterbanks::Bank.list

      expect(banks.class).to eq(Afterbanks::Collection)
      expect(banks.size).to eq(4)

      bank1, bank2, bank3, bank4 = banks

      expect(bank1.class).to eq(Afterbanks::Bank)
      expect(bank1.country_code).to eq("ES")
      expect(bank1.service).to eq("N26")
      expect(bank1.swift).to eq("NTSBDEB1")
      expect(bank1.fullname).to eq("N26")
      expect(bank1.business).to be_falsey
      expect(bank1.documenttype).to eq("0")
      expect(bank1.user).to eq("Correo electrónico")
      expect(bank1.pass).to eq("Contraseña")
      expect(bank1.pass2).to eq("0")
      expect(bank1.userdesc).to eq("")
      expect(bank1.passdesc).to eq("")
      expect(bank1.pass2desc).to eq("")
      expect(bank1.usertype).to eq("text")
      expect(bank1.passtype).to eq("text")
      expect(bank1.pass2type).to eq("text")
      expect(bank1.image).to eq("https://www.afterbanks.com/api/icons/n26.min.png")
      expect(bank1.color).to eq("DBF8FC")

      expect(bank2.class).to eq(Afterbanks::Bank)
      expect(bank2.country_code).to eq("ES")
      expect(bank2.service).to eq("bbva")
      expect(bank2.swift).to eq("BBVAESMM")
      expect(bank2.fullname).to eq("BBVA")
      expect(bank2.business).to be_falsey
      expect(bank2.documenttype).to eq("0")
      expect(bank2.user).to eq("Usuario")
      expect(bank2.pass).to eq("Clave")
      expect(bank2.pass2).to eq("0")
      expect(bank2.userdesc).to eq("")
      expect(bank2.passdesc).to eq("")
      expect(bank2.pass2desc).to eq("")
      expect(bank2.usertype).to eq("text")
      expect(bank2.passtype).to eq("text")
      expect(bank2.pass2type).to eq("text")
      expect(bank2.image).to eq("https://www.afterbanks.com/api/icons/bbva.min.png")
      expect(bank2.color).to eq("BBC6E1")

      expect(bank3.class).to eq(Afterbanks::Bank)
      expect(bank3.country_code).to eq("ES")
      expect(bank3.service).to eq("caixa_emp")
      expect(bank3.swift).to eq("CAIXESBB")
      expect(bank3.fullname).to eq("Caixabank")
      expect(bank3.business).to be_truthy
      expect(bank3.documenttype).to eq("0")
      expect(bank3.user).to eq("Identificación")
      expect(bank3.pass).to eq("PIN1")
      expect(bank3.pass2).to eq("0")
      expect(bank3.userdesc).to eq("")
      expect(bank3.passdesc).to eq("")
      expect(bank3.pass2desc).to eq("")
      expect(bank3.usertype).to eq("text")
      expect(bank3.passtype).to eq("text")
      expect(bank3.pass2type).to eq("text")
      expect(bank3.image).to eq("https://www.afterbanks.com/api/icons/caixa.min.png")
      expect(bank3.color).to eq("B2D4F4")

      expect(bank4.class).to eq(Afterbanks::Bank)
      expect(bank4.country_code).to eq("ES")
      expect(bank4.service).to eq("sabadell")
      expect(bank4.swift).to eq("BSABESBB")
      expect(bank4.fullname).to eq("Banco Sabadell")
      expect(bank4.business).to be_falsey
      expect(bank4.documenttype).to eq("0")
      expect(bank4.user).to eq("Usuario")
      expect(bank4.pass).to eq("Clave de acceso")
      expect(bank4.pass2).to eq("0")
      expect(bank4.userdesc).to eq("")
      expect(bank4.passdesc).to eq("")
      expect(bank4.pass2desc).to eq("")
      expect(bank4.usertype).to eq("text")
      expect(bank4.passtype).to eq("tel")
      expect(bank4.pass2type).to eq("text")
      expect(bank4.image).to eq("https://www.afterbanks.com/api/icons/sabadell.min.png")
      expect(bank4.color).to eq("B2E0EF")
    end
  end
end