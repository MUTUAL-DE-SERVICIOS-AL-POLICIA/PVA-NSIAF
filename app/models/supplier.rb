class Supplier < ActiveRecord::Base
  has_many :note_entries

  def self.search_supplier(q)
    where("name LIKE ?", "%#{q}%").map { |s| { id: s.id, name: s.name } }
  end

  def self.get_id(name)
    supplier = where(name: name)
    if supplier.present?
      supplier.first.id
    else
      supplier = Supplier.new(name: name)
      supplier.save
      supplier.id
    end
  end
end
