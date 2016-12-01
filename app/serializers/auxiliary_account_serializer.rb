class AuxiliaryAccountSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :name, :cantidad_assets, :monto_assets

  def cantidad_assets
    object.assets.count
  end

  def monto_assets
    object.sumatoria_precio_activos
  end
end
