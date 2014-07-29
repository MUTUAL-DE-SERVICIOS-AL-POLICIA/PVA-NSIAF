class BarcodeStatusValidator
  def initialize(asset)
    @asset = asset
  end

  def validate
    barcode = Barcode.find_by_code @asset.barcode
    barcode.present? && barcode.is_free?
  end
end
