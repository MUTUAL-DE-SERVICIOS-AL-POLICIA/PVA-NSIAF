class BarcodeStatus < ActiveRecord::Base
  self.primary_key = 'status'

  has_many :barcodes, foreign_key: 'status'
end
