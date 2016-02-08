class Transaccion < ActiveRecord::Base
  self.table_name = 'entradas_salidas'

  belongs_to :subarticle

  def self.entradas
    where(tipo: 'entrada')
  end

  # Despliega el saldo total de la lista
  # No funciona cuando hay un objeto adicionado dinámicamente
  def self.saldo
    all.sum(:cantidad)
  end

  def self.salidas
    where(tipo: 'salida')
  end

  # Permite obtener el saldo a una determinada fecha en un objeto transaccion
  def self.saldo_al(fecha = Date.today)
    transacciones = all.where('fecha <= ?', fecha)
    unless transacciones.count.zero?
      saldo = transacciones.sum(:cantidad) # total que hay
      entradas = []
      transacciones.entradas.reverse.each do |entrada|
        entradas.prepend(entrada)
        entrada.fecha = fecha
        if (saldo - entrada.cantidad) > 0
          saldo -= entrada.cantidad
        else
          entrada.cantidad = saldo
          break
        end
      end
      return entradas
    end
    return nil
  end

  def saldo
    cantidad
  end

  def saldo_inicial?
    !modelo_id.present?
  end
end
