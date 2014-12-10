class Kardex < ActiveRecord::Base
  default_scope -> {order(:created_at)}

  belongs_to :subarticle

  has_many :kardex_prices

  accepts_nested_attributes_for :kardex_prices

  def self.final_kardex
    sd = Date.today.beginning_of_year
    ed = Date.today.end_of_year
    kardex = Kardex.where(kardex_date: sd..ed).last
    if kardex.nil?
      kardex = Kardex.new
      kardex.kardex_prices.build
    else
        kardex = kardex.replicate
        kardex.reset_kardex_prices
        kardex.remove_zero_balance
        kardex.kardex_date = Date.today
        kardex.invoice_number = 0
        kardex.delivery_note_number = 0
        kardex.order_number = 0
        kardex.detail = 'SALDO FINAL'
        kardex.sum_inputs
        kardex.sum_outputs
    end
    kardex
  end

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

  def first_kardex_price(unit_cost)
    kardex_price = nil
    kardex_prices.reverse.each do |kp|
      if kp.unit_cost == unit_cost
        kardex_price = kp
      end
    end
    kardex_price
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

  def remove_zero_balance
    if kardex_prices.length > 1
      k_prices = []
      kardex_prices.each do |kardex_price|
        if kardex_price.balance_quantities.zero?
          k_prices << kardex_price
        end
      end
      kardex_prices.delete(k_prices)
    end
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
    delivery_note_number = nil
    order_number = nil
    detail = nil
    kardex_prices.each do |kardex_price|
      kardex_price.input_quantities = 0
      kardex_price.output_quantities = 0
      kardex_price.input_amount = 0
      kardex_price.output_amount = 0
    end
  end

  def sum_inputs
    kardex_price = kardex_prices.first
    kardex_price.sum_inputs(subarticle) if kardex_price
    (kardex_prices - [kardex_price]).each do |kp|
      kp.input_quantities = kp.balance_quantities ####
      kp.input_amount = kp.balance_amount
      kardex_price.input_quantities -= kp.input_quantities
    end

  end

  def sum_outputs
    kardex_price = kardex_prices.first
    kardex_price.sum_outputs(subarticle) if kardex_price
    (kardex_prices - [kardex_price]).each do |kp|
      kp.output_quantities = 0
      kp.output_amount = 0
    end
  end

  def sum_balance_quantities
    balance = 0
    kardex_prices.each do |kp|
      balance += kp.balance_quantities
    end
    balance
  end
end
