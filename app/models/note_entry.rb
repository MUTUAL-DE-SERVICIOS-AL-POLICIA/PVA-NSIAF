class NoteEntry < ActiveRecord::Base
  belongs_to :supplier
  has_many :entry_subarticles
  accepts_nested_attributes_for :entry_subarticles
  belongs_to :user

  def supplier_name
    supplier.present? ? supplier.name : ''
  end

  def user_name
    user.present? ? user.name : ''
  end
end
