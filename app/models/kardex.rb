class Kardex < ActiveRecord::Base
  belongs_to :subarticle

  has_many :kardex_prices

  def self.initial_kardex
    kardex = Kardex.new
    kardex.kardex_prices.build
    kardex
  end
end
