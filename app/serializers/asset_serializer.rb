class AssetSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :description, :detalle, :barcode, :observaciones, :urls

  def urls
    {
      show: asset_url(object, host: Rails.application.secrets.rails_host)
    }
  end

end
