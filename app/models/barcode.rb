class Barcode < ActiveRecord::Base
  belongs_to :entity
  belongs_to :barcode_status, foreign_key: 'status'

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
end
