require "spec_helper"

describe Afterbanks::Bank do
  describe "#list" do
    before do
      stub_request(:get, "https://api.afterbanks.com/forms/").
        to_return(
          status: 200,
          body: response_json(resource: 'bank', action: 'list'),
          headers: { debug_id: 'banklist1234' }
        )
    end

    it "returns the proper Afterbanks::Bank instances with the adequate name changes" do
      # Name changes:
      # 1. Add Particulares if there are different personal/company endpoints
      # 2. Add Empresas following the same reason
      # 3. Rename Caja Ingenieros into Caixa d'Enginyers

      response = Afterbanks::Bank.list

      expect(response.class).to eq(Afterbanks::Response)
      expect(response.debug_id).to eq('banklist1234')

      banks = response.result

      expect(banks.class).to eq(Afterbanks::Collection)
      expect(banks.size).to eq(6)

      bank1, bank2, bank3, bank4, bank5, bank6 = banks

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
      expect(bank2.fullname).to eq("BBVA Particulares")
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
      expect(bank3.service).to eq("bbva_emp")
      expect(bank3.swift).to eq("BBVAESMM")
      expect(bank3.fullname).to eq("BBVA Net Cash Empresas")
      expect(bank3.business).to be_truthy
      expect(bank3.documenttype).to eq("0")
      expect(bank3.user).to eq("Código de empresa")
      expect(bank3.pass).to eq("Usuario")
      expect(bank3.pass2).to eq("Contraseña")
      expect(bank3.userdesc).to eq("")
      expect(bank3.passdesc).to eq("")
      expect(bank3.pass2desc).to eq("")
      expect(bank3.usertype).to eq("text")
      expect(bank3.passtype).to eq("text")
      expect(bank3.pass2type).to eq("text")
      expect(bank3.image).to eq("https://www.afterbanks.com/api/icons/bbva.min.png")
      expect(bank3.color).to eq("BBC6E1")

      expect(bank4.class).to eq(Afterbanks::Bank)
      expect(bank4.country_code).to eq("ES")
      expect(bank4.service).to eq("caixa_emp")
      expect(bank4.swift).to eq("CAIXESBB")
      expect(bank4.fullname).to eq("Caixabank Empresas")
      expect(bank4.business).to be_truthy
      expect(bank4.documenttype).to eq("0")
      expect(bank4.user).to eq("Identificación")
      expect(bank4.pass).to eq("PIN1")
      expect(bank4.pass2).to eq("0")
      expect(bank4.userdesc).to eq("")
      expect(bank4.passdesc).to eq("")
      expect(bank4.pass2desc).to eq("")
      expect(bank4.usertype).to eq("text")
      expect(bank4.passtype).to eq("text")
      expect(bank4.pass2type).to eq("text")
      expect(bank4.image).to eq("https://www.afterbanks.com/api/icons/caixa.min.png")
      expect(bank4.color).to eq("B2D4F4")

      expect(bank5.class).to eq(Afterbanks::Bank)
      expect(bank5.country_code).to eq("ES")
      expect(bank5.service).to eq("cajaingenieros")
      expect(bank5.swift).to eq("CDENESBB")
      expect(bank5.fullname).to eq("Caixa d'Enginyers")
      expect(bank5.business).to be_falsey
      expect(bank5.documenttype).to eq("0")
      expect(bank5.user).to eq("Código de usuario")
      expect(bank5.pass).to eq("Clave de acceso")
      expect(bank5.pass2).to eq("0")
      expect(bank5.userdesc).to eq("")
      expect(bank5.passdesc).to eq("")
      expect(bank5.pass2desc).to eq("")
      expect(bank5.usertype).to eq("text")
      expect(bank5.passtype).to eq("tel")
      expect(bank5.pass2type).to eq("text")
      expect(bank5.image).to eq("https://www.afterbanks.com/api/icons/cajaingenieros.min.png")
      expect(bank5.color).to eq("6FC1FF")

      expect(bank6.class).to eq(Afterbanks::Bank)
      expect(bank6.country_code).to eq("ES")
      expect(bank6.service).to eq("sabadell")
      expect(bank6.swift).to eq("BSABESBB")
      expect(bank6.fullname).to eq("Banco Sabadell")
      expect(bank6.business).to be_falsey
      expect(bank6.documenttype).to eq("0")
      expect(bank6.user).to eq("Usuario")
      expect(bank6.pass).to eq("Clave de acceso")
      expect(bank6.pass2).to eq("0")
      expect(bank6.userdesc).to eq("")
      expect(bank6.passdesc).to eq("")
      expect(bank6.pass2desc).to eq("")
      expect(bank6.usertype).to eq("text")
      expect(bank6.passtype).to eq("tel")
      expect(bank6.pass2type).to eq("text")
      expect(bank6.image).to eq("https://www.afterbanks.com/api/icons/sabadell.min.png")
      expect(bank6.color).to eq("B2E0EF")
    end

    context "when passing the :ordered flag" do
      it "returns the proper Afterbanks::Bank instances with the adequate name changes,  ordered by fullname" do
        response = Afterbanks::Bank.list(ordered: true)

        expect(response.class).to eq(Afterbanks::Response)
        expect(response.debug_id).to eq('banklist1234')

        banks = response.result

        expect(banks.class).to eq(Afterbanks::Collection)
        expect(banks.size).to eq(6)

        bank1, bank2, bank3, bank4, bank5, bank6 = banks

        expect(bank1.class).to eq(Afterbanks::Bank)
        expect(bank1.country_code).to eq("ES")
        expect(bank1.service).to eq("sabadell")
        expect(bank1.swift).to eq("BSABESBB")
        expect(bank1.fullname).to eq("Banco Sabadell")
        expect(bank1.business).to be_falsey
        expect(bank1.documenttype).to eq("0")
        expect(bank1.user).to eq("Usuario")
        expect(bank1.pass).to eq("Clave de acceso")
        expect(bank1.pass2).to eq("0")
        expect(bank1.userdesc).to eq("")
        expect(bank1.passdesc).to eq("")
        expect(bank1.pass2desc).to eq("")
        expect(bank1.usertype).to eq("text")
        expect(bank1.passtype).to eq("tel")
        expect(bank1.pass2type).to eq("text")
        expect(bank1.image).to eq("https://www.afterbanks.com/api/icons/sabadell.min.png")
        expect(bank1.color).to eq("B2E0EF")

        expect(bank2.class).to eq(Afterbanks::Bank)
        expect(bank2.country_code).to eq("ES")
        expect(bank2.service).to eq("bbva_emp")
        expect(bank2.swift).to eq("BBVAESMM")
        expect(bank2.fullname).to eq("BBVA Net Cash Empresas")
        expect(bank2.business).to be_truthy
        expect(bank2.documenttype).to eq("0")
        expect(bank2.user).to eq("Código de empresa")
        expect(bank2.pass).to eq("Usuario")
        expect(bank2.pass2).to eq("Contraseña")
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
        expect(bank3.service).to eq("bbva")
        expect(bank3.swift).to eq("BBVAESMM")
        expect(bank3.fullname).to eq("BBVA Particulares")
        expect(bank3.business).to be_falsey
        expect(bank3.documenttype).to eq("0")
        expect(bank3.user).to eq("Usuario")
        expect(bank3.pass).to eq("Clave")
        expect(bank3.pass2).to eq("0")
        expect(bank3.userdesc).to eq("")
        expect(bank3.passdesc).to eq("")
        expect(bank3.pass2desc).to eq("")
        expect(bank3.usertype).to eq("text")
        expect(bank3.passtype).to eq("text")
        expect(bank3.pass2type).to eq("text")
        expect(bank3.image).to eq("https://www.afterbanks.com/api/icons/bbva.min.png")
        expect(bank3.color).to eq("BBC6E1")

        expect(bank4.class).to eq(Afterbanks::Bank)
        expect(bank4.country_code).to eq("ES")
        expect(bank4.service).to eq("cajaingenieros")
        expect(bank4.swift).to eq("CDENESBB")
        expect(bank4.fullname).to eq("Caixa d'Enginyers")
        expect(bank4.business).to be_falsey
        expect(bank4.documenttype).to eq("0")
        expect(bank4.user).to eq("Código de usuario")
        expect(bank4.pass).to eq("Clave de acceso")
        expect(bank4.pass2).to eq("0")
        expect(bank4.userdesc).to eq("")
        expect(bank4.passdesc).to eq("")
        expect(bank4.pass2desc).to eq("")
        expect(bank4.usertype).to eq("text")
        expect(bank4.passtype).to eq("tel")
        expect(bank4.pass2type).to eq("text")
        expect(bank4.image).to eq("https://www.afterbanks.com/api/icons/cajaingenieros.min.png")
        expect(bank4.color).to eq("6FC1FF")

        expect(bank5.class).to eq(Afterbanks::Bank)
        expect(bank5.country_code).to eq("ES")
        expect(bank5.service).to eq("caixa_emp")
        expect(bank5.swift).to eq("CAIXESBB")
        expect(bank5.fullname).to eq("Caixabank Empresas")
        expect(bank5.business).to be_truthy
        expect(bank5.documenttype).to eq("0")
        expect(bank5.user).to eq("Identificación")
        expect(bank5.pass).to eq("PIN1")
        expect(bank5.pass2).to eq("0")
        expect(bank5.userdesc).to eq("")
        expect(bank5.passdesc).to eq("")
        expect(bank5.pass2desc).to eq("")
        expect(bank5.usertype).to eq("text")
        expect(bank5.passtype).to eq("text")
        expect(bank5.pass2type).to eq("text")
        expect(bank5.image).to eq("https://www.afterbanks.com/api/icons/caixa.min.png")
        expect(bank5.color).to eq("B2D4F4")

        expect(bank6.class).to eq(Afterbanks::Bank)
        expect(bank6.country_code).to eq("ES")
        expect(bank6.service).to eq("N26")
        expect(bank6.swift).to eq("NTSBDEB1")
        expect(bank6.fullname).to eq("N26")
        expect(bank6.business).to be_falsey
        expect(bank6.documenttype).to eq("0")
        expect(bank6.user).to eq("Correo electrónico")
        expect(bank6.pass).to eq("Contraseña")
        expect(bank6.pass2).to eq("0")
        expect(bank6.userdesc).to eq("")
        expect(bank6.passdesc).to eq("")
        expect(bank6.pass2desc).to eq("")
        expect(bank6.usertype).to eq("text")
        expect(bank6.passtype).to eq("text")
        expect(bank6.pass2type).to eq("text")
        expect(bank6.image).to eq("https://www.afterbanks.com/api/icons/n26.min.png")
        expect(bank6.color).to eq("DBF8FC")
      end
    end
  end

  describe "serialization" do
    let(:country_code) { 'ES' }
    let(:service) { 'caixa_emp' }
    let(:swift) { 'CAIXESBB' }
    let(:fullname) { 'Caixabank Empresas' }
    let(:business) { true }
    let(:documenttype) { '0' }
    let(:user) { 'Identificación' }
    let(:pass) { 'PIN1' }
    let(:pass2) { '0' }
    let(:userdesc) { '' }
    let(:passdesc) { '' }
    let(:pass2desc) { '' }
    let(:usertype) { 'text' }
    let(:passtype) { 'text' }
    let(:pass2type) { 'text' }
    let(:image) { 'https://www.afterbanks.com/api/icons/caixa.min.png' }
    let(:color) { 'B2D4F4' }
    let(:original_bank) do
      Afterbanks::Bank.new(
        country_code: country_code,
        service: service,
        swift: swift,
        fullname: fullname,
        business: business,
        documenttype: documenttype,
        user: user,
        pass: pass,
        pass2: pass2,
        userdesc: userdesc,
        passdesc: passdesc,
        pass2desc: pass2desc,
        usertype: usertype,
        passtype: passtype,
        pass2type: pass2type,
        image: image,
        color: color
      )
    end

    it "works" do
      serialized_bank = Marshal.dump(original_bank)
      recovered_bank = Marshal.load(serialized_bank)

      expect(recovered_bank.class).to eq(Afterbanks::Bank)
      expect(recovered_bank.country_code).to eq("ES")
      expect(recovered_bank.service).to eq("caixa_emp")
      expect(recovered_bank.swift).to eq("CAIXESBB")
      expect(recovered_bank.fullname).to eq("Caixabank Empresas")
      expect(recovered_bank.business).to be_truthy
      expect(recovered_bank.documenttype).to eq("0")
      expect(recovered_bank.user).to eq("Identificación")
      expect(recovered_bank.pass).to eq("PIN1")
      expect(recovered_bank.pass2).to eq("0")
      expect(recovered_bank.userdesc).to eq("")
      expect(recovered_bank.passdesc).to eq("")
      expect(recovered_bank.pass2desc).to eq("")
      expect(recovered_bank.usertype).to eq("text")
      expect(recovered_bank.passtype).to eq("text")
      expect(recovered_bank.pass2type).to eq("text")
      expect(recovered_bank.image).to eq("https://www.afterbanks.com/api/icons/caixa.min.png")
      expect(recovered_bank.color).to eq("B2D4F4")
    end
  end
end
