class BarcodeStatusValidator
  def initialize(asset)
    @asset = asset
  end

  def validate
    barcode = Barcode.find_by_code @asset.barcode
    if !barcode.present? || !barcode.is_free?
      @asset.errors[:base] << "Este Código de Barras no existe o ya está en uso"
    end
  end
end
