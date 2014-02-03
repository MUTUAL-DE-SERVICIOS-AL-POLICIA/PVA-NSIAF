class Building < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'UNIDAD' => 'code',
    'DESCRIP' => 'name',
    'ENTIDAD' => 'entity_id'
  }

  belongs_to :entity

  validates :name, :entity_id, presence: true
  validates :code, presence: true, uniqueness: true

  def entity_name
    entity.present? ? entity.name : ''
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    CORRELATIONS.each { |k, v| print "#{record[k].inspect}, " }
    building = Hash.new
    CORRELATIONS.each do |origin, destination|
      building.merge!({ destination => record[origin] })
    end
    new(building).save(validate: false) if building.present?
  end
end
