class BarcodeStatusValidator
  def initialize(barcode_object)
    @barcode_object = barcode_object
  end

  def validate
    barcode = Barcode.find_by_code @barcode_object.barcode
    if @barcode_object.barcode != @barcode_object.barcode_was
      if !barcode.present? || !barcode.is_free?
        @barcode_object.errors.add(:barcode, "no existe o ya está en uso")
      end
    end
  end
end
