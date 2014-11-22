class EntrySubarticle < ActiveRecord::Base
  belongs_to :subarticle
  belongs_to :note_entry

  #validates :amount, :invoice, presence: true, numericality: { only_integer: true, greater_than: 0 }
  #validates :unit_cost, :total_cost, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than: 10000000 }

  before_create :set_stock_value

  def subarticle_name
    subarticle.present? ? subarticle.description : ''
  end

  def subarticle_code
    subarticle.present? ? subarticle.code : ''
  end

  def subarticle_unit
    subarticle.present? ? subarticle.unit : ''
  end

  def decrease_amount
    if self.stock > 0
      self.stock = self.stock - 1
      self.save
    else
      Rails.logger.info "No se pudo decrementar porque no es mayor a cero"
    end
  end

  private

  def set_stock_value
    self.stock = amount
  end
end
