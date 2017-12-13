class Select2AjaxResourcesController < ApplicationController
  before_action :set_current_user

  def get_warehouse
    query = select2_params.values_at(:q).join(" ")
    data = JSON.parse($jurnal.warehouse_api.get_warehouses(@token, query))
    data["warehouses"].insert(0, {"id" => "", "name" => "Unassigned"})
    render json: { data: data }
  end

  def get_tag
    query = select2_params.values_at(:q).join(" ")
    render json: { data: JSON.parse($jurnal.tags_api.get_select2_tags(@token, query)) }
  end

  def get_account
    query = select2_params.values_at(:q).join(" ")
    priority = select2_params.values_at(:priority).join(" ")
    type = select2_params.values_at(:type).join(" ")
    
    render json: { data: JSON.parse($jurnal.account_api.get_select2_accounts(@token, query, type, priority)) }
  end

  private
    def set_current_user
      @user = current_user
      @token = JurnalAccessToken.where(user_id: @user.id).last.code
    end

    def select2_params
      # initialize
      temp_param = {}

      if params.present?
        temp_param = params.permit(:q, :type, :priority)
      end

      temp_param
    end
end
