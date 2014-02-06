class Building < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'UNIDAD' => 'code',
    'DESCRIP' => 'name'
  }

  belongs_to :entity

  validates :code, presence: true, uniqueness: { scope: :entity_id }
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :entity_id, presence: true

  before_create :building_active

  def change_status
    state = self.status == '0' ? '1' : '0'
    self.update_attribute(:status, state)
  end

  def entity_code
    entity.present? ? entity.code : ''
  end

  def entity_name
    entity.present? ? entity.name : ''
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    building = Hash.new
    CORRELATIONS.each do |origin, destination|
      building.merge!({ destination => record[origin] })
    end
    e = Entity.find_by_code(record['ENTIDAD'])
    e.present? && building.present? && new(building.merge!({ entity: e })).save
  end

  def building_active
    self.status = '1'
  end
end
