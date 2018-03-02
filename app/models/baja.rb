class Baja < ActiveRecord::Base
  include Autoincremento
  has_many :assets
  belongs_to :user

  # método que verifica si baja tiene un código.
  def tiene_codigo?
    codigo.present?
  end

  # Método para obtener el siguiente codigo de activo.
  def self.obtiene_siguiente_codigo
    Baja.all.empty? ? 1 : Baja.maximum(:codigo) + 1
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'codigo'), h.get_column(self, 'documento'), h.get_column(self, 'fecha'), h.get_column(self, 'observacion')]
  end
end
