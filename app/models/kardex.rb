class Kardex < ActiveRecord::Base
  belongs_to :subarticle

  has_many :kardex_prices
end
