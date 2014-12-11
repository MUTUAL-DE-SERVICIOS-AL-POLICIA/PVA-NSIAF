class SubarticleRequest < ActiveRecord::Base
  belongs_to :subarticle
  belongs_to :request

  after_update :create_kardex_price

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

  def self.user_requests
    joins(subarticle: [{article: :material}, :entry_subarticles], request: [user: :department]).group("subarticle_requests.subarticle_id").select("subarticles.code, subarticles.description, sum(subarticle_requests.amount) as total_amount, requests.created_at, max(entry_subarticles.unit_cost) as max_cost").where('entry_subarticles.unit_cost = (SELECT MAX(entry_subarticles.unit_cost) FROM entry_subarticles WHERE entry_subarticles.subarticle_id = subarticles.id)').order('max(entry_subarticles.unit_cost) DESC').first(10)
  end

  private

  # Register in kardex when delivery subarticles
  def create_kardex_price
    if total_delivered == amount_delivered && total_delivered-1 == total_delivered_was
      kardex = subarticle.last_kardex
      if kardex.present?
        kardex = kardex.replicate
        kardex.reset_kardex_prices
        kardex.remove_zero_balance

        kardex.kardex_date = nil
        kardex.invoice_number = 0
        kardex.delivery_note_number = 0
        kardex.order_number = request.id
        kardex.detail = request.user_name_title
        kardex.request = request

        total = total_delivered.to_i
        kardex.kardex_prices.each do |kardex_price|
          if total > 0
            total = kardex_price.decrease_amount(total)
          end
        end

        kardex.save!
      end
    end
  end
end
