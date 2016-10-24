class Alerta < ActiveRecord::Base
  scope :activos, -> { where.not(baja_logica: nil) }
  belongs_to :procedimiento

  def ejecuta_procedimiento
    clase = self.procedimiento.try(:clase)
    metodo = self.procedimiento.try(:metodo)
    Class.class_eval("#{clase}.#{metodo}") if clase.present? && metodo.present?
  end
end
