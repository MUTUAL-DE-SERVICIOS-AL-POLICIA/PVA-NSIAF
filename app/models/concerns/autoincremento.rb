module Autoincremento
  extend ActiveSupport::Concern

  included do
    validate :establecer_incremento_creacion, on: :create
    validate :establecer_incremento_actualizacion, on: :update
  end

  def establecer_incremento_creacion
    if self.present?
      case self.class.name
      when 'Subarticle'
        autoincremento_subarticulo(self)
      when 'NoteEntry'
        autoincremento_notas_ingreso if (self.nro_nota_ingreso == nil || self.nro_nota_ingreso == 0) && self.invoice_date.present?
      when 'Ingreso'
        autoincremento_ingresos unless self.numero.present?
      end
    end
  end

  def establecer_incremento_actualizacion
    if self.present?
      case self.class.name
      when 'NoteEntry'
        autoincremento_notas_ingreso if (self.nro_nota_ingreso == nil || self.nro_nota_ingreso == 0) && self.invoice_date.present?
      when 'Ingreso'
        autoincremento_ingresos unless self.numero.present?
      end
    end
  end

  def autoincremento_subarticulo(subarticulo)
    if incremento.blank?
      registros = material.send(subarticulo.class.name.tableize)
      max_incremento = registros.maximum(:incremento)
      subarticulo.incremento = max_incremento.to_i + 1
    end
  end

  def autoincremento_notas_ingreso
    respuesta = NoteEntry.obtiene_siguiente_nro_nota_ingreso(self.invoice_date)
    if respuesta[:codigo_numerico].present? && (self.nro_nota_ingreso == 0 || self.nro_nota_ingreso == nil)
      self.nro_nota_ingreso = respuesta[:codigo_numerico]
      self.incremento_alfabetico = respuesta[:codigo_alfabetico] if respuesta[:codigo_alfabetico].present?
    end
  end

  def autoincremento_ingresos
    respuesta = Ingreso.obtiene_siguiente_numero_ingreso(self.factura_fecha)
    if respuesta[:codigo_numerico].present? && self.numero == nil
      self.numero = respuesta[:codigo_numerico]
      self.incremento_alfabetico = respuesta[:codigo_alfabetico] if respuesta[:codigo_alfabetico].present?
    end
  end
end
