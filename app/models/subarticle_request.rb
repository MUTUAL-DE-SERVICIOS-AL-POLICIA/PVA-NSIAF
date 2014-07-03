class SubarticleRequest < ActiveRecord::Base
  belongs_to :subarticle
  belongs_to :request

  def subarticle_unit
    subarticle.present? ? subarticle.unit : ''
  end

  def subarticle_description
    subarticle.present? ? subarticle.description : ''
  end

  def subarticle_code
    subarticle.present? ? subarticle.code : ''
  end

  def subarticle_barcode
    subarticle.present? ? subarticle.barcode : ''
  end
end
