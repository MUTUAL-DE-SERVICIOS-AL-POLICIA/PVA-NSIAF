class Barcode < ActiveRecord::Base
  belongs_to :entity
  belongs_to :barcode_status, foreign_key: 'status'

  validates :code, uniqueness: true

  def self.register_assets(assets)
    if assets.length > 0
      acronym = assets.first[:code].split('-').first
      entity = Entity.find_by_acronym acronym
      transaction do
        assets.each do |asset|
          create({code: asset[:code], entity: entity, status: BarcodeStatus::INITIAL})
        end
        Rails.logger.info "#{assets.length} Códigos de Barras insertados"
      end
    end
  end

  def change_to_deleted
    self.status = BarcodeStatus::DELETED
    self.save!
  end

  def change_to_used
    self.status = BarcodeStatus::USED
    self.save!
  end

  def is_free?
    status == BarcodeStatus::INITIAL
  end
end
