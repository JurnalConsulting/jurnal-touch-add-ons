class PaymentMethod < ApplicationRecord
  belongs_to :setting, optional: true

  def get_fee(amount)
    (self.payment_fee_percentage.to_f.to_d / 100 * amount.to_f.to_d) + self.payment_fee_fixed.to_f.to_d
  end

  def is_cash?(name)
    (name == "Cash" || name == "Kas Tunai") ? true : false
  end
end
