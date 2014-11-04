class EntrySubarticle < ActiveRecord::Base
  belongs_to :subarticle

  validates :amount, :invoice, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_cost, :total_cost, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than: 10000000 }
  validates :date, presence: true
end
