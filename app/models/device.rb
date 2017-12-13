class Device < ApplicationRecord
  acts_as_paranoid
	belongs_to :setting
  has_many :entries, :foreign_key => 'device_id',  :class_name => 'Transaction'
  
  attr_accessor :location
  reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.location = geo.city + ', ' + geo.country
    end
  end

  def sales_this_month
    query = "SELECT sum(amount) from transactions where device_id = #{self.id} and date >= '#{Date.today.beginning_of_month}' and date <= 'Date.today.end_of_month' group by device_id"
    result = ActiveRecord::Base.connection.execute(query)
    return result.first.present? ? result.first[0] : 0
  end

  def sales_this_year
    query = "SELECT sum(amount) from transactions where device_id = #{self.id} and date >= '#{Date.today.beginning_of_year}' and date <= 'Date.today.end_of_year' group by device_id"
    result = ActiveRecord::Base.connection.execute(query)
    return result.first.present? ? result.first[0] : 0
  end

  def last_sync
    a = self.entries.reorder("created_at desc").limit(1)
    return a.present? ? a.first.created_at : nil
  end
end
