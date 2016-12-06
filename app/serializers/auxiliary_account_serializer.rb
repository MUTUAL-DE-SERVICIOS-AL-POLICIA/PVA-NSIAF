class AuxiliaryAccountSerializer < ActiveModel::Serializer

  self.root = false
  attributes  :id, :codigo, :nombre, :cantidad_activos, :monto_activos

  def codigo
    object.code
  end

  def nombre
    object.name
  end
end
