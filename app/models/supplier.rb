class Supplier < ActiveRecord::Base
  has_many :note_entries

  def self.search_supplier(q)
    where("name LIKE ?", "%#{q}%").map { |s| { id: s.id, name: s.name } }
  end

  def self.new_object(name)
    supplier = Supplier.new(name: name)
    supplier.save
    return supplier.id
  end
end
