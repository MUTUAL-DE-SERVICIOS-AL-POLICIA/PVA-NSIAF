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

  def self.get_subarticle(subarticle_id)
    where(subarticle_id: subarticle_id).first
  end

  def increase_total_delivered
    increase = total_delivered + 1
    update_attribute('total_delivered', increase)
  end

  def self.is_delivered?
    where('total_delivered < amount_delivered').present?
  end

  def self.user_requests(user_id)
    joins(:subarticle, :request).group("subarticle_id").where("requests.user_id = ?", user_id).select("subarticles.description, sum(subarticle_requests.amount) as total_amount, requests.created_at")
  end
end
