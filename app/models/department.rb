class Department < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'ENTIDAD' => 'building_id',
    'CODOFIC' => 'code',
    'NOMOFIC' => 'name',
    'API_ESTADO' => 'status'
  }

  belongs_to :building

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :building_id, presence: true

  before_create :department_inactive

  def change_status
    state = self.status == '0' ? '1' : '0'
    self.update_attribute(:status, state)
  end

  def building_name
    building.present? ? building.name : ''
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    # TODO falta asociar con el Edificio, y tambien su Estado (A, C, y D)
    CORRELATIONS.each { |k, v| print "#{record[k].inspect}, " }
    department = Hash.new
    CORRELATIONS.each do |origin, destination|
      department.merge!({ destination => record[origin] })
    end
    new(department).save(validate: false) if department.present?
  end

  def department_inactive
    self.status = '0'
  end
end
