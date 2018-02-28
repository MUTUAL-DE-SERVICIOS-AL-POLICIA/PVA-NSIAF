class Baja < ActiveRecord::Base
  include Autoincremento
  has_many :assets
  belongs_to :user

  # método que verifica si baja tiene un código.
  def tiene_codigo?
    numero.present?
  end

  # Método para obtener el siguiente codigo de activo.
  def self.obtiene_siguiente_codigo
    Baja.all.empty? ? 1 : Baja.maximum(:numero) + 1
  end
end
