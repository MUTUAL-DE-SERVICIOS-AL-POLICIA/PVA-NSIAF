class MaterialRequest < ActiveRecord::Base
  belongs_to :material
  belongs_to :request

  def material_unit
    material.present? ? material.unit : ''
  end

  def material_description
    material.present? ? material.description : ''
  end

  def material_code
    material.present? ? material.code : ''
  end
end
