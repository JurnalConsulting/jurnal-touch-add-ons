class Setting < ApplicationRecord
  has_many:payment_methods, :dependent => :destroy
  has_many:devices, :dependent => :destroy
  belongs_to :user
  
  attr_accessor :warehouse
  def inject_param(param)
    tag_ids  = self.tag_ids.present? ? self.tag_ids.split(",") : nil
    param = param.merge({tags_id: tag_ids, 
                warehouse_id: self.warehouse_id, 
                person_id: self.user.person_id})
    return param
  end
end
