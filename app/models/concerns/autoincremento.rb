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
        autoincremento_notas_ingreso(self)
      end
    end
  end

  def establecer_incremento_actualizacion
    if self.present?
      case self.class.name
      when 'NoteEntry'
        autoincremento_notas_ingreso(self)
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

  def autoincremento_notas_ingreso(nota_ingreso)
    if nota_ingreso.nro_nota_ingreso == 0 && nota_ingreso.invoice_date.present?
      fecha = nota_ingreso.invoice_date.to_date
      nro_nota_anterior = NoteEntry.nro_nota_ingreso_anterior(fecha)
      nro_nota_posterior = NoteEntry.nro_nota_ingreso_posterior(fecha)
      if nro_nota_anterior.present? && !nro_nota_posterior.present?
        nota_ingreso.nro_nota_ingreso = nro_nota_anterior.to_i + 1
      elsif !nro_nota_anterior.present? && !nro_nota_posterior.present?
        nota_ingreso.nro_nota_ingreso = 1
      elsif nro_nota_anterior.present? && nro_nota_posterior.present?
        diferencia = nro_nota_posterior - nro_nota_anterior
        if diferencia > 1
          nota_ingreso.nro_nota_ingreso = nro_nota_anterior.to_i + 1
        else
          inc_alfabetico = NoteEntry.nro_nota_ingreso_posterior_regularizado(fecha)
          if inc_alfabetico.present?
            "no se puede contactese con el administrador"
          else
            max_incremento_alfabetico = NoteEntry.where(nro_nota_ingreso: nro_nota_anterior).order(incremento_alfabetico: :desc).first.incremento_alfabetico
            nota_ingreso.nro_nota_ingreso = nro_nota_anterior.to_i
            nota_ingreso.incremento_alfabetico = max_incremento_alfabetico.present? ? max_incremento_alfabetico.next : "A"
          end
        end
      else
        nota_ingreso.nro_nota_ingreso = nro_nota_posterior.to_i - 1
      end
    end
  end
end
