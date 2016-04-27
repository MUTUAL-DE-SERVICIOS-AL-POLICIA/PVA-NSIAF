class Ingreso < ActiveRecord::Base
  belongs_to :supplier
  has_many :assets

  def supplier_name
    supplier.present? ? supplier.name : ''
  end

  def supplier_nit
    supplier.present? ? supplier.nit : ''
  end
end
