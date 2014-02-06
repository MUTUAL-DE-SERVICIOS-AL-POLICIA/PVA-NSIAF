class Department < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'CODOFIC' => 'code',
    'NOMOFIC' => 'name',
    'API_ESTADO' => 'status'
  }

  belongs_to :building

  validates :code, presence: true, uniqueness: { scope: :building_id }
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z|\"|\.|-/u }, allow_blank: true
  validates :building_id, presence: true

  before_create :department_inactive

  def change_status
    state = self.status == '0' ? '1' : '0'
    self.update_attribute(:status, state)
  end

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

  def department_inactive
    self.status = '1'
  end
end
