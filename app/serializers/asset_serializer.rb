class AssetSerializer < ActiveModel::Serializer
  self.root = false
  attributes :code, :description, :barcode, :observaciones
end
