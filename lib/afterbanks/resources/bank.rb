module Afterbanks
  class Bank < Resource
    has_fields country_code: :string,
               service: :string,
               swift: :string,
               fullname: :string,
               business: :boolean,
               documenttype: :string,
               user: :string,
               pass: :string,
               pass2: :string,
               userdesc: :string,
               passdesc: :string,
               pass2desc: :string,
               usertype: :string,
               passtype: :string,
               pass2type: :string,
               image: :string,
               color: :string

    def self.list
      response = Afterbanks.api_call(
        method: :get,
        path: '/forms/'
      )
      Collection.new(response, self)
    end
  end
end
