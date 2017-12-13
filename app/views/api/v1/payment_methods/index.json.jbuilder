json.payment_methods @payment_methods_list do |payment_method|
	json.id payment_method.id
	json.name payment_method.name
end
