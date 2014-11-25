class Kardex < ActiveRecord::Base
  belongs_to :subarticle

  has_many :kardex_prices

  accepts_nested_attributes_for :kardex_prices

  def self.initial_kardex
    sd = Date.today.beginning_of_year
    ed = Date.today.end_of_year
    kardex = Kardex.where(kardex_date: sd..ed).first
    if kardex.nil?
      kardex = Kardex.new
      kardex.kardex_prices.build
    end
    kardex
  end

  def last_kardex_price(unit_cost)
    kardex_price = nil
    kardex_prices.each do |kp|
      if kp.unit_cost == unit_cost
        kardex_price = kp
      end
    end
    kardex_price
  end

  def replicate
    replica = dup
    kardex_prices.each do |kardex_price|
      replica.kardex_prices << kardex_price.dup
    end
    replica
  end

  def reset_kardex_prices
    kardex_date = nil
    invoice_number = nil
    order_number = nil
    detail = nil
    kardex_prices.each do |kardex_price|
      kardex_price.input_quantities = 0
      kardex_price.output_quantities = 0
      kardex_price.input_amount = 0
      kardex_price.output_amount = 0
    end
  end
end
