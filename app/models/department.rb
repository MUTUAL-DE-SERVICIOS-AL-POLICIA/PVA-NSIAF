class Department < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODOFIC' => 'code',
    'NOMOFIC' => 'name',
    'API_ESTADO' => 'status'
  }

  belongs_to :building

  validates :code, presence: true, uniqueness: { scope: :building_id }
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z|\"|\.|-/u }, allow_blank: true
  validates :building_id, presence: true

  has_paper_trail ignore: [:status, :updated_at]

  def building_code
    building.present? ? building.code : ''
  end

  def building_name
    building.present? ? building.name : ''
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    department = Hash.new
    CORRELATIONS.each do |origin, destination|
      department.merge!({ destination => record[origin] })
    end
    b = Building.find_by_code(record['UNIDAD'])
    b.present? && department.present? && new(department.merge!({ building: b })).save
  end
end
