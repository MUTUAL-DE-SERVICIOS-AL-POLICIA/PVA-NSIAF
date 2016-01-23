class Transaccion < ActiveRecord::Base
  self.table_name = 'entradas_salidas'

  belongs_to :subarticle

  # Despliega el saldo total de la lista
  # No funciona cuando hay un objeto adicionado dinámicamente
  def self.saldo
    all.sum(:cantidad)
  end

  # Instanciar un objecto transacción
  def self.saldo_inicial(fecha = Date.today)
    cantidad = all.where('fecha < ?', fecha).sum(:cantidad)
    Transaccion.new(cantidad: cantidad)
  end

  def saldo
    cantidad
  end

  def saldo_inicial?
    !modelo_id.present?
  end
end
