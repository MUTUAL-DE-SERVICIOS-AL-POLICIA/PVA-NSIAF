class AssetAccountSerializer < ActiveModel::Serializer
  self.root = false
  attributes  :id, :codigo, :descripcion, :auxiliar, :precio

  def codigo
    object.code
  end

  def descripcion
    object.description
  end

  def auxiliar
    object.name
  end
end