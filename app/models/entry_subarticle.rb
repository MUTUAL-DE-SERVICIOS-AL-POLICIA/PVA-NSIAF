class EntrySubarticle < ActiveRecord::Base
  default_scope {where(invalidate: false).order(:created_at)}

  belongs_to :subarticle
  belongs_to :note_entry

  #validates :amount, :invoice, presence: true, numericality: { only_integer: true, greater_than: 0 }
  #validates :unit_cost, :total_cost, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than: 10000000 }

  before_create :set_stock_value
  before_create :set_date_value
  after_create :create_kardex_price

  # Anula las entradas de subartículos, estableciendo el campo invalidate a true
  def self.invalidate_entries
    update_all(invalidate: true)
  end

  def self.replicate
    all.map { |e| e.dup }
  end

  def self.years_not_closed
    years = select(:date).where('stock > ?', 0)
    years = years.map { |e| e.date.present? ? e.date.year : nil }
    years.compact.uniq
  end

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

  def set_date_value
    if note_entry.present?
      self.date = note_entry.note_entry_date
    end
  end

  private

  def set_stock_value
    self.stock = amount
  end


  # Register in kardex when purchase subarticles (note entries)
  def create_kardex_price
    kardex = subarticle.last_kardex
    if kardex.present?
      kardex = kardex.replicate
      kardex_price = kardex.last_kardex_price(unit_cost)
    else
      kardex = subarticle.kardexes.new
    end
    kardex.reset_kardex_prices
    kardex.remove_zero_balance
    kardex_price = kardex.kardex_prices.new unless kardex_price.present?

    balance = amount
    balance += kardex_price.balance_quantities

    if note_entry.present?
      kardex.note_entry = note_entry
      kardex.kardex_date = note_entry.note_entry_date
      kardex.invoice_number = note_entry.get_invoice_number
      kardex.delivery_note_number = note_entry.get_delivery_note_number
      kardex.detail = note_entry.supplier_name
      kardex.order_number = 0
      kardex_price.input_quantities = amount
      kardex_price.input_amount = amount * unit_cost
    else
      kardex.kardex_date = self.date
      kardex.invoice_number = 0
      kardex.delivery_note_number = 0
      kardex.detail = 'SALDO INICIAL'
      kardex.order_number = 0
      kardex_price.input_quantities = 0
      kardex_price.input_amount = 0
    end
    kardex_price.output_quantities = 0
    kardex_price.balance_quantities = balance
    kardex_price.unit_cost = unit_cost
    kardex_price.output_amount = 0
    kardex_price.balance_amount = balance * unit_cost
    kardex.save!
  end
end
