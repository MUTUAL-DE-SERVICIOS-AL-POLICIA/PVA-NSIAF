class Account < ActiveRecord::Base
  include ImportDbf, VersionLog

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name'
  }

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
    end
    array
  end

  def self.to_csv(column_names)
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
end
