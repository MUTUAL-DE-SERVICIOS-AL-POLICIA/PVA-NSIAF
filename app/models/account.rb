class Account < ActiveRecord::Base
  include ImportDbf, VersionLog

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name',
    'VIDAUTIL' => 'vida_util',
    'DEPRECIAR' => 'depreciar',
    'ACTUALIZAR' => 'actualizar'
  }

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_many :auxiliaries
  has_many :assets

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("code LIKE ? OR name LIKE ? OR vida_util LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code name vida_util)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |account|
        csv << account.attributes.values_at(*columns)
      end
    end
  end

  def self.with_assets
    conditions = { assets: { id: nil } }
    joins(:assets).where.not(conditions).uniq
  end
end
