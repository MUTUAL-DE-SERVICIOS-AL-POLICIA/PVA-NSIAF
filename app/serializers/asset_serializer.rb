class AssetSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :description, :detalle, :barcode, :observaciones, :precio, :urls

  def urls
    {
      show: asset_url(object)
    }
  end

end
