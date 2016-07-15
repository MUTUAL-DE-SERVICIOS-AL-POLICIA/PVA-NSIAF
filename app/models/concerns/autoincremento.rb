module Autoincremento
  extend ActiveSupport::Concern

  included do
    validate :establecer_incremento, on: :create
  end

  def establecer_incremento
    debugger
    if incremento.blank?
      registros = material.send(self.class.name.tableize)
      max_incremento = registros.maximum(:incremento)

      self.incremento = max_incremento.to_i + 1
    end
  end
end
