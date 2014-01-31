class Building < ActiveRecord::Base
  belongs_to :entity

  validates :name, :entity_id, presence: true
  validates :code, presence: true, uniqueness: true

  def entity_name
    entity.present? ? entity.name : ''
  end
end
