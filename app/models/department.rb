class Department < ActiveRecord::Base
  belongs_to :building

  validates :code, :name, :building_id, presence: true

  def building_name
    building.present? ? building.name : ''
  end
end
