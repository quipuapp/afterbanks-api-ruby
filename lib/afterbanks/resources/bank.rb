module Afterbanks
  class Bank < Resource
    RESOURCE_PATH = '/forms/'

    has_fields :country_code, :service, :swift, :fullname, :business,
      :documenttype, :user, :pass, :pass2, :userdesc, :passdesc, :pass2desc,
      :usertype, :passtype, :pass2type, :image, :color

    def self.list
      response = Afterbanks.api_call(
        method: :get,
        path: RESOURCE_PATH
      )
      Collection.new(response, self)
    end
  end
end
