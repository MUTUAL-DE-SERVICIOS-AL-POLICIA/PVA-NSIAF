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
end
