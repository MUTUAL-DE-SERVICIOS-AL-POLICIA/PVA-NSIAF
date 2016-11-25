class SubarticleRequest < ActiveRecord::Base
  default_scope {where(invalidate: false)}
  
  belongs_to :subarticle
  belongs_to :request

  after_update :create_kardex_price

  def self.invalidate_subarticles
    update_all(invalidate: true)
  end

  # Se entrega todos los subartículos solicitados haciendo la resta al stock
  def self.entregar_subarticulos
    all.each do |subarticle_request|
      subarticle_request.entregar_subarticulo
    end
  end

  # Realiza la iteracion de las solicitudes de subarticulo con la cantidad a
  # entregar.
  def self.validar_cantidades(cantidades_subarticulo)
    resultado = []
    all.each do |solic_subart|
      cantidad_subarticulo = cantidades_subarticulo.select { |s| s['id'] == solic_subart.id.to_s }
      resultado << solic_subart.validar_cantidad(cantidad_subarticulo.first)
    end
    resultado
  end

  # Realizar la resta del stock al subartículo
  def entregar_subarticulo
    subarticle.entregar_subarticulo(amount_delivered)
    incremento_total_delivered(amount_delivered)
  end

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

  # Obtiene el stock disponible del subarticulo asociado.
  def subarticle_stock
    subarticle.present? ? subarticle.stock : 0
  end

  def self.get_subarticle(subarticle_id)
    where(subarticle_id: subarticle_id).first
  end

  def increase_total_delivered
    increase = total_delivered + 1
    update_attribute('total_delivered', increase)
  end

  def incremento_total_delivered(cantidad)
    update_attribute('total_delivered', cantidad)
  end

  # Verificación de la cantidad a entregar sea mayor o igual a 0, sea menor o
  # igual al stock y a la cantidad solicitada
  def validar_cantidad(cantidad_subarticulo)
    cantidad_entregar = cantidad_subarticulo['cantidad'].to_i
    verificacion = true
    mensaje = ''
    if cantidad_entregar > subarticle.stock
      mensaje = 'La cantidad a entregar es mayor al stock disponible.'
      verificacion = false
    end
    { id: id, verificacion: verificacion, mensaje: mensaje }
  end

  def self.is_delivered?
    where('total_delivered < amount_delivered').present?
  end

  def self.user_requests(date)
    request = joins(subarticle: [{article: :material}, :entry_subarticles], request: [user: :department]).group("subarticle_requests.subarticle_id").select("subarticles.code, subarticles.description, sum(subarticle_requests.amount) as total_amount, requests.created_at, max(entry_subarticles.unit_cost) as max_cost").where('entry_subarticles.unit_cost = (SELECT MAX(entry_subarticles.unit_cost) FROM entry_subarticles WHERE entry_subarticles.subarticle_id = subarticles.id)').order('max(entry_subarticles.unit_cost) DESC')
    request = request.where("requests.created_at >= ? AND requests.created_at <= ?", Time.now.beginning_of_day, Time.now.end_of_day) if date
    return request
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
