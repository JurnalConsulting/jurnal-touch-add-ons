class User < ApplicationRecord
	has_many :settings
	has_many :jurnal_access_tokens
  has_many :devices, through: :settings
  has_many :authentication_tokens


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  

  def initialize_user(access_token, company_data)
    if self.new_record?
      self.id = company_data.id
      self.name = company_data.name
      self.password = company_data.email
      self.email = access_token.code + '@email'
      self.logo_url = company_data.logo_url
      company_details_data = Jurnal::Company::CompanyDetailsResponse.new(
                              JSON.parse($jurnal.company_api.get_company_details(access_token.code, company_data.id)))
      self.phone = company_details_data.phone
      self.fax = company_details_data.fax
      self.address = company_details_data.address
      self.company_website = company_details_data.company_website
      self.default_invoice_message = company_details_data.default_invoice_message
      self.company_package = company_details_data.company_package
      
      attempt = nil
      person_id = nil
      while person_id.nil? and attempt.to_f < 10 do
        person_id = ::Jurnal::Person::PersonResponse.new(JSON.parse($jurnal.person_api.create_person(access_token.code, attempt))).id
        attempt = attempt.to_i + 1
      end
      
      self.person_id = person_id
      self.save!
    end
  end
end
