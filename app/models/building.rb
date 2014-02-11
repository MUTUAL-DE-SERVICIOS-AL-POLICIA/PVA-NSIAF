class Building < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus

  CORRELATIONS = {
    'UNIDAD' => 'code',
    'DESCRIP' => 'name'
  }

  belongs_to :entity

  validates :code, presence: true, uniqueness: { scope: :entity_id }
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :entity_id, presence: true

  has_paper_trail ignore: [:status, :updated_at]

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
end
