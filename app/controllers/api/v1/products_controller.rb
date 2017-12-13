class Api::V1::ProductsController < Api::V1::ApiController
  before_action :authenticate_user!
  respond_to :json

  def index
    @products_data = JSON.parse($jurnal.product_api.get_products(@jurnal_access_token.code, params[:page])) 
  end
end
