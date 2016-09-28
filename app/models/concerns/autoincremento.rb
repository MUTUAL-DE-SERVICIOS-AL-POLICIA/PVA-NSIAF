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
        autoincremento_notas_ingreso if self.nro_nota_ingreso == 0 && self.invoice_date.present?
      end
    end
  end

  def establecer_incremento_actualizacion
    if self.present?
      case self.class.name
      when 'NoteEntry'
        autoincremento_notas_ingreso if self.nro_nota_ingreso == 0 && self.invoice_date.present?
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
    codigo_numerico, codigo_alfabetico, _ = NoteEntry.obtiene_siguiente_nro_nota_ingreso(self.invoice_date)
    if codigo_numerico.present?
      self.nro_nota_ingreso = codigo_numerico if codigo_numerico.present?
      self.incremento_alfabetico = codigo_alfabetico if codigo_alfabetico.present?
    end
  end

end
