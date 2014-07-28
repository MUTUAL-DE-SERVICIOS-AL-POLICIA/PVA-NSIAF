class Barcode < ActiveRecord::Base
  belongs_to :entity
  belongs_to :barcode_status, foreign_key: 'status'
end
