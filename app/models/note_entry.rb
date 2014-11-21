class NoteEntry < ActiveRecord::Base
  belongs_to :supplier
  has_many :entry_subarticles
  accepts_nested_attributes_for :entry_subarticles

  def supplier_name
    supplier.present? ? supplier.name : ''
  end
end
