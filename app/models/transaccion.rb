class Transaccion < ActiveRecord::Base
  self.table_name = 'entradas_salidas'

  belongs_to :subarticle

  attr_accessor :cantidad_entrada
  attr_accessor :cantidad_salida
  attr_accessor :cantidad_saldo
  attr_accessor :items

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
        #entrada.detalle = ''
        entrada.cantidad_saldo = entrada.cantidad
        entrada.cantidad = 0 # Para saldos iniciales
        if (saldo - entrada.cantidad_saldo) > 0
          saldo -= entrada.cantidad_saldo
        else
          entrada.cantidad_saldo = saldo
          break
        end
      end
      return entradas
    end
    return nil
  end

  #def cantidad_entrada
  #  cantidad >= 0 ? cantidad : 0
  #end

  #def cantidad_salida
#    cantidad <= 0 ? (-1) * cantidad : 0
#  end

  def crear_items(saldos)
    # Limpiar campos
    saldos.each { |s| s.cantidad_entrada=0; s.cantidad_salida=0}
    # Verificar si es resta o adición
    if cantidad > 0
      # TODO hay que considerar el caso que haya otro con el mismo precio
      duplicado = self.dup
      duplicado.cantidad_entrada = duplicado.cantidad
      duplicado.cantidad_salida = 0
      duplicado.cantidad_saldo = duplicado.cantidad
      saldos << duplicado # Adicionar saldo
    else
      # Empezar a restar de los saldos
      numero = -cantidad
      saldos.each do |saldo|
        resto = saldo.cantidad_saldo - numero
        saldo.cantidad_entrada = 0
        if resto > 0
          saldo.cantidad_salida = numero
          saldo.cantidad_saldo = resto
          break
        else
          saldo.cantidad_salida = numero + resto
          saldo.cantidad_saldo = 0
          numero = -resto
        end
      end
    end
    self.items = saldos
    saldos.map { |s| s.dup }
  end

  def importe_entrada
    cantidad_entrada.to_f * costo_unitario
  end

  def importe_salida
    cantidad_salida.to_f * costo_unitario
  end

  def importe_saldo
    cantidad_saldo.to_f * costo_unitario
  end

  def saldo
    cantidad
  end

  def saldo_inicial?
    !modelo_id.present?
  end
end
