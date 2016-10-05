class AssetSerializer < ActiveModel::Serializer
  attributes :code, :description, :barcode, :observaciones
end
