class BarcodeStatus < ActiveRecord::Base
  INITIAL = 0
  USED = 1
  DELETED = 2

  self.primary_key = 'status'

  has_many :barcodes, foreign_key: 'status'
end
