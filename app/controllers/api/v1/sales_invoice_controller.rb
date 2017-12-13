class Api::V1::SalesInvoiceController < Api::V1::ApiController
  before_action :authenticate_user!
  respond_to :json
  
  def create
    param = @setting.inject_param(transaction_split_params)
    if param[:custom_id].present?
      exist = Transaction.where(custom_id: param[:custom_id]).first
      if exist.present?
        render json: {id: exist.transaction_id, transaction_no: exist.transaction_no}, status: 201
        return
      end
    end  

    begin
      res = ::Jurnal::Transaction::CreateInvoiceResponse.new(
            JSON.parse(
              $jurnal.transaction_api.create_sales_invoice(@jurnal_access_token.code, param.merge(source: @device.device_type))))
      
      if res.errors.present?
        render json: {errors: res.errors}, status: 422
        return
      end

      

      payment_type = @setting.payment_methods.where(payment_type_id: param[:payment_type_id]).first

      if res.id.present? && res.original_amount.to_f <= 0
        render json: {id: res.id, transaction_no: res.transaction_no}, status: 201
        return
      end
      
      if res.id.present? && payment_type.present?
        payment = ::Jurnal::Transaction::CreatePaymentResponse.new(
            JSON.parse(
              $jurnal.transaction_api.create_payment(@jurnal_access_token.code, {
                transaction_date: param[:transaction_date],
                transaction_id: res.id,
                amount: res.original_amount,
                person_id: param[:person_id],
                payment_method_id: param[:payment_method_id],
                deposit_to_id: payment_type.payment_account_id,
                memo: param[:payment_memo],
                tags_id: param[:tags_id],
                witholding_account_id: payment_type.payment_fee_account_id,
                witholding_type: "value",
                source: @device.device_type,
                witholding_value: payment_type.get_fee(res.original_amount)
                })))
        if payment.id.present?
          Transaction.create!(date: param[:transaction_date], 
                              device_id: @device.id, 
                              transaction_id: res.id, 
                              transaction_no: res.transaction_no,
                              payment_id: payment.id, 
                              payment_method_id: param[:payment_method_id], 
                              amount:res.original_amount,
                              custom_id: param[:custom_id])
          render json: {id: res.id, transaction_no: res.transaction_no}, status: 201
          return
        else
          $jurnal.transaction_api.delete_invoice(@jurnal_access_token.code, {id: res.id})
          render json: {}, status: 422
          return
        end
      else  
        render json: {errors: "Payment type id can't be null or not found"}, status: 422
        return
      end
    rescue => e
      render json: {}, status: 422
      return
    end
  end

  private

  def transaction_split_params
    temp_param = params.require(:sales_invoice).permit(:transaction_date, :discount_type_id,
                                         :discount_unit, :payment_memo, :payment_type_id, :custom_id,
                                         :memo, :transaction_lines_attributes => 
                                          [:product_id, :quantity, :description, :rate, :discount ,:line_tax_id])
    return temp_param
  end
end