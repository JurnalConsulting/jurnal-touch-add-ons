class Api::V1::PaymentMethodsController < Api::V1::ApiController
  before_action :authenticate_user!
  respond_to :json

   def index
   	@payment_methods = PaymentMethod.where(setting_id: @setting.id)
    @payment_methods_list = []
    @payment_methods.each do |payment_method|
      payment_method = ::Jurnal::PaymentMethod::GetPaymentMethodResponse.new(
            JSON.parse(
              $jurnal.payment_method_api.get_payment_method(@jurnal_access_token.code, payment_method.payment_type_id)))
      @payment_methods_list << payment_method
    end
   end
end
