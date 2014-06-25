class SubarticleRequest < ActiveRecord::Base
  belongs_to :subarticle
  belongs_to :request

  def material_unit
    subarticle.present? ? subarticle.unit : ''
  end

  def material_description
    subarticle.present? ? subarticle.description : ''
  end

  def material_code
    subarticle.present? ? subarticle.code : ''
  end
end
