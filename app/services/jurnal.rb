class Jurnal
  require "net/http"
  require "uri"
  OK = "200"
  CREATED = "201"

  class Company
    class ActiveCompanyResponse
      attr_reader :name, :email, :errors, :logo_url,:id, :company_package
      def initialize(param)
        @id = param["company"].try(:[], "id")
        @name = param["company"].try(:[], "name")
        @email = param["company"].try(:[], "company_email")
        @logo_url = param["company"].try(:[], "logo")
        @company_package = param["company_package"]
        @errors = param["errors"]
      end
    end

    class CompanyDetailsResponse
      attr_reader :id, :name, :email, :logo_url, :phone, :company_package, :fax, :address, :company_website, :default_invoice_message
      def initialize(param)
        @id = param["company"].try(:[], "id")
        @phone = param["company"].try(:[], "phone")
        @fax = param["company"].try(:[], "fax")
        @address = param["company"].try(:[], "address")
        @company_website = param["company"].try(:[], "company_website")
        @default_invoice_message = param["company"].try(:[], "default_invoice_message")
        @name = param["company"].try(:[], "name")
        @email = param["company"].try(:[], "company_email")
        @logo_url = param["company"].try(:[], "logo")
        @company_package = param["company_package"]
        @errors = param["errors"]
      end
    end

    class CompanyBillingDetailResponse
      attr_reader :devices
      def initialize(param)
        @devices = param["company"].try(:[], "jurnal_touch_devices") || 1
      end
    end

    def get_active_company(credential)
      path = '/companies/active'
      response = Jurnal.get(credential, path)
      return response
    end

    def get_company_details(credential, company_id)
      path = "/companies/#{company_id}"
      response = Jurnal.get(credential, path)
      return response
    end

    def billing_details(credential, company_id)
      path = "/companies/#{company_id}/billing_details"
      response = Jurnal.get(credential, path)
      return response
    end

  end

  class Account
    class AccountResponse
      class AccountData
        attr_reader :id, :name, :number, :category
        def initialize(param)
          @id = param["id"]
          @name = param["name"]
          @number = param["number"]
          @category = param["category"]
        end
      end

      attr_reader :other, :expense, :cash_bank, :errors
      def initialize(param)
        @other = []
        @expense = []
        @cash_bank = []
        @errors = param["errors"]
        if param["accounts"].present?
          param["accounts"].each do |x|
            account = Jurnal::Account::AccountResponse::AccountData.new(x)
            if x["category_id"] == 3
              @cash_bank << account
            elsif x["category_id"] == 16 || x["category_id"] == 17 ||  x["category_id"] == 15
              @expense << account 
            else
              @other << account
            end
          end
        end
      end
    end

    def get_accounts(credential)
      path = "/accounts"
      response =  Jurnal.get(credential, path)
      return response
    end

    def get_select2_accounts(credential, query = '', type = 'account', priority = 'all')
      path = "/select2_resources/get_account?type=#{type}&priority=#{priority}&category=&page=all&size=all&q=#{query}"
      response = Jurnal.get_internal(credential, path)
      return response
    end
  end

  class Warehouse
    class GetWarehousesResponse
      class WarehouseData
        attr_reader :id, :name
        def initialize(param)
          @id = param["id"]
          @name = param["name"]
        end
      end

      attr_reader :warehouses
      def initialize(param)
        @warehouses = []
        if param["warehouses"].present?
          param["warehouses"].each do |x|
            warehouse = Jurnal::Warehouse::GetWarehousesResponse::WarehouseData.new(x)
            @warehouses << warehouse
          end
          default_warehouse = Jurnal::Warehouse::GetWarehousesResponse::WarehouseData.new({"id" => "", "name" => "Unassigned"})
          @warehouses.insert(0,default_warehouse)
        end
      end

      def to_a
        self.warehouses
      end
    end
    
    def get_warehouses(credential, query = '')
      path = "/warehouses?key=#{query}"
      
      response = Jurnal.get(credential, path)
      return response
    end
  end

  class Tags
    class GetTagsResponse
      class TagsData
        attr_reader :id, :name
        def initialize(param)
          @id = param["id"]
          @name = param["name"]
        end
      end

      attr_reader :tags_list
      def initialize(param)
        @tags_list = []
        if param["tags"].present?
          param["tags"].each do |x|
            tags = Jurnal::Tags::GetTagsResponse::TagsData.new(x)
            @tags_list << tags
          end
        end
      end
      
      def to_a
        self.tags_list
      end
    end

    def get_tags(credential)
      path = '/tags'
      
      response = Jurnal.get(credential, path)
      return response
    end

    def get_select2_tags(credential, query = '')
      path = "/select2_resources/get_taggings?page=all&type=tag&size=all&q=#{query}"
      response = Jurnal.get_internal(credential, path)
      return response
    end
  end

  class PaymentMethod
    class GetPaymentMethodsResponse
      class PaymentMethodData
        attr_reader :id, :name
        def initialize(param)
          @id = param["id"]
          @name = param["name"]
        end
      end

      attr_reader :payment_methods
      def initialize(param)
        @payment_methods = []
        if param["payment_methods"].present?
          param["payment_methods"].each do |x|
            payment_method = Jurnal::PaymentMethod::GetPaymentMethodsResponse::PaymentMethodData.new(x)
            @payment_methods << payment_method
          end
        end
      end
    end
    class GetPaymentMethodResponse
      attr_reader :id, :name
      def initialize(param)
        @id = param["payment_method"].try(:[], "id")
        @name = param["payment_method"].try(:[], "name")
      end
    end
    def get_payment_methods(credential)
      path = '/payment_methods'
      response = Jurnal.get(credential, path)
      return response
    end

    def get_payment_method(credential, id)
      path = "/payment_methods/#{id}"
      response = Jurnal.get(credential, path)
      return response
    end

    def create_payment_method(credential, payment_method_data)
      path = '/payment_methods'
      data = {
        payment_method: {
          name: payment_method_data[:name]
        }
      }
      response = Jurnal.post(credential, path, data)
      return response
    end
  end

  class Transaction
    class CreateInvoiceResponse
      attr_reader :id, :transaction_no,:original_amount, :errors
      def initialize(param)
        @id = param["sales_invoice"].try(:[], "id")
        @transaction_no = param["sales_invoice"].try(:[], "transaction_no")
        @original_amount =  param["sales_invoice"].try(:[], "original_amount")
        @errors = param["error_full_messages"]
      end
    end

    class CreatePaymentResponse
      attr_reader :id, :transaction_no
      def initialize(param)
        @id = param["receive_payment"].try(:[], "id")
        @transaction_no = param["receive_payment"].try(:[], "transaction_no")
      end
    end

    class GetSalesInvoicesResponse
      attr_reader :this_month, :this_year
      def initialize(params)
        range_this_month = Date.today.beginning_of_month..Date.today
        range_this_year = Date.today.beginning_of_year..Date.today

        @this_month = 0
        @this_year = 0
        params["sales_invoices"].each do |param|
          @this_year += param["amount_receive"].to_f if range_this_year === param["created_at"].to_date
          @this_month += param["amount_receive"].to_f if range_this_month === param["created_at"].to_date
        end
      end
    end

    def get_sales_invoice(credential)
      path = '/sales_invoices'
      response = Jurnal.get(credential, path)
      return response
    end

    def create_sales_invoice(credential, sales_invoice_data)
      path = '/sales_invoices'
      lines =  []
      sales_invoice_data[:transaction_lines_attributes].each do |x|
        lines <<  {
                    quantity: x[:quantity],
                    rate: x[:rate],
                    description: x[:description],
                    product_id: x[:product_id],
                    line_tax_id: x[:line_tax_id],
                    discount: x[:discount]
                  }
      end

      data = {
              sales_invoice: {
                discount_type_id: sales_invoice_data[:discount_type_id],
                discount_unit: sales_invoice_data[:discount_unit],
                person_id: sales_invoice_data[:person_id],
                transaction_date: sales_invoice_data[:transaction_date],
                due_date: sales_invoice_data[:transaction_date],
                transaction_lines_attributes: lines,
                warehouse_id: sales_invoice_data[:warehouse_id],
                tag_ids: sales_invoice_data[:tags_id],
                source: sales_invoice_data[:source],
                memo: sales_invoice_data[:memo],
                description: sales_invoice_data[:description],
                custom_id: sales_invoice_data[:custom_id]
              }
            }
      response = Jurnal.post(credential, path, data)
      return response
    end

    def delete_invoice(credential, data)
      path =  "/sales_invoices/#{data[:id]}"
      response = Jurnal.delete(credential, path)
    end

    def create_payment(credential, transaction_data)
      path ='/receive_payments'
      data = {
                receive_payment: {
                  transaction_date: transaction_data[:transaction_date],
                  records_attributes: [
                    {
                      transaction_id: transaction_data[:transaction_id],
                      amount: transaction_data[:amount]
                    }
                  ],
                  person_id: transaction_data[:person_id],
                  custom_id: transaction_data[:id],
                  payment_method_id: transaction_data[:payment_method_id],
                  is_draft: false,
                  deposit_to_id: transaction_data[:deposit_to_id],
                  tag_ids: transaction_data[:tags_id],
                  memo: transaction_data[:memo],
                  witholding_account_id: transaction_data[:witholding_account_id],
                  witholding_value: transaction_data[:witholding_value],
                  witholding_type: "value",
                  source: transaction_data[:source]
                }
              }
      response = Jurnal.post(credential, path, data)
      return response
    end
  end


  class Product
    class GetProductsResponse
      class ProductData
        attr_reader :id, :name, :sell_price, :image_url
        def initialize(param)
          @id = param["id"]
          @name = param["name"]
          @sell_price_per_unit = param["sell_price_per_unit"]
          @image_url = param["image"]["url"]
          @description = param["description"]
          @unit = param["unit"]["name"]
          @category = param["product_categories"]
        end
      end

      attr_reader :products
      def initialize(param)
        @products = []
        @total_count = param["total_count"]
        @current_page = param["current_page"]
        @total_page = param["total_pages"]
        @link = param["links"]
        if param["products"].present?
          param["products"].each do |x|
            product = Jurnal::Product::GetProductsResponse::ProductData.new(x)
            @products << product
          end
        end
      end
    end

    def get_products(credential, page)
      path = '/products?detail=1&is_sold=1'
      if page.present?
        path += "&page=#{page}"
      end
      p path
      response = ::Jurnal.get(credential, path)
      return response
    end
  end


  class Person
    class PersonResponse
      attr_reader :id, :errors
      def initialize(param)
        @id = param.try(:[], "customer").try(:[], "id")
        @errors = param["error_full_messages"]
      end
    end

    def get_person(credential)
      ''
    end

    def create_person(credential, attempt)
      path ='/customers'
      data =  {
        customer: {
          display_name: "Default Customer - Jurnal Touch #{attempt}",
          is_lock: true,
          source: "JurnalTouch"
        }
      }
      response = Jurnal.post(credential, path, data)
    end
  end

  attr_reader :company_api, :account_api, 
              :warehouse_api, :payment_method_api, 
              :product_api, :tags_api, 
              :transaction_api, :person_api
  def initialize
    @company_api = Jurnal::Company.new
    @account_api = Jurnal::Account.new
    @warehouse_api = Jurnal::Warehouse.new
    @payment_method_api = Jurnal::PaymentMethod.new
    @transaction_api = Jurnal::Transaction.new
    @product_api = Jurnal::Product.new
    @tags_api = Jurnal::Tags.new
    @person_api = ::Jurnal::Person.new
  end

  def self.get(credential, path)
    uri = URI.parse(ENV['JURNAL_ROOT_PATH'] + path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{credential}"
    request['X-Jurnal-Locale'] = "en"
    
    begin
      Rails.logger.info("request: #{request.body}")
      response = http.request(request)
      Rails.logger.info("response: #{response.body}")
      return response.body
    rescue => e
      Rails.logger.info("error: #{e}")
      {errors: e}
    end
  end

  def self.get_internal(credential, path)
    uri = URI.parse(ENV['JURNAL_ROOT_INTERNAL_PATH'] + path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Authorization'] = "Bearer #{credential}"
    request['X-Jurnal-Locale'] = "en"
    
    begin
      Rails.logger.info("request: #{request.body}")
      response = http.request(request)
      Rails.logger.info("response: #{response.body}")
      return response.body
    rescue => e
      Rails.logger.info("error: #{e}")
      {errors: e}
    end
  end

  def self.post(credential, path, data)
    uri = URI.parse(ENV['JURNAL_ROOT_PATH'] + path) 
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Authorization'] = "Bearer #{credential}"
    request['Content-Type'] = "application/json"
    request['X-Jurnal-Locale'] = "en"
    request.body = data.to_json
    begin
      Rails.logger.info("request: #{request.body}")
      response = http.request(request)
      Rails.logger.info("response: #{response.body}")
      return response.body
    rescue => e
      Rails.logger.info("error: #{e}")
      {errors: e}
    end
  end

  def self.delete(credential, path)
    uri = URI.parse(ENV['JURNAL_ROOT_PATH'] + path) 
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Delete.new(uri.request_uri)
    request['Authorization'] = "Bearer #{credential}"
    request['Content-Type'] = "application/json"
    request['X-Jurnal-Locale'] = "en"
    begin
      Rails.logger.info("request: #{request.body}")
      response = http.request(request)
      Rails.logger.info("response: #{response.body}")
      return response.body
    rescue => e
      Rails.logger.info("error: #{e}")
      {errors: e}
    end
  end 
end