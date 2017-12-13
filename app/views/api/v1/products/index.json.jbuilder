json.products @products_data["products"] do |product|
	if product["archive"] == false
		json.id product["id"]
		json.name product["name"]
		json.sell_price_per_unit product["sell_price_per_unit"]
		json.description product["description"]
		json.unit product["unit"]
		json.product_code product["product_code"]
		json.category product["product_categories"] do |category|
			json.id category["id"]
			json.name category["name"]
		end
		if product['image'].present?
			json.image do
				json.name product["image"]["name"]
				json.url product["image"]["url"]
				json.mini_url product["image"]["mini_url"]
			end
		end

		json.is_system product["is_system"]
		json.sell_tax product['sell_tax']
		if product['sell_tax'].present?
			json.sell_tax do
				json.id product["sell_tax"]["id"]
				json.name product["sell_tax"]["name"]
				json.rate product["sell_tax"]["rate"]
				json.is_witholding product["sell_tax"]["is_witholding"]
				json.is_compound product["sell_tax"]["is_compound"]
			end
		end

		if product['sell_tax_detail'].present?
			json.sell_tax_detail product["sell_tax_detail"] do |tax|
				json.id tax["id"]
				json.name tax["name"]
				json.rate tax["rate"]
				json.is_witholding tax["is_witholding"]
				json.is_compound tax["is_compound"]
			end
		end
		
	end
end
json.total_count @products_data["total_count"]
json.current_page @products_data["current_page"]
json.total_pages @products_data["total_pages"]
json.links do
	if @products_data["links"].present? && @products_data["links"]["next_link"].present?
		json.next_link @products_data["links"]["next_link"].sub! 'https://api.jurnal.id/partner/core', 'hehe'
	end
	if @products_data["links"].present? && @products_data["links"]["prev_link"].present?
		json.prev_link @products_data["links"]["prev_link"].sub! 'https://api.jurnal.id/partner/core', 'hehe'
	end
end
