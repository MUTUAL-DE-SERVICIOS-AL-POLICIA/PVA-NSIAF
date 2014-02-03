class Department < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'ENTIDAD' => 'building_id',
    'CODOFIC' => 'code',
    'NOMOFIC' => 'name',
    'API_ESTADO' => 'status'
  }

  belongs_to :building

  validates :code, :name, :building_id, presence: true

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
end
