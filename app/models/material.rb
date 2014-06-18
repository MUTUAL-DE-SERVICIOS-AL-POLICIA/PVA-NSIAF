class Material < ActiveRecord::Base
  has_many :material_requests
  has_many :requests, through: :material_requests

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'unit'), h.get_column(self, 'description')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    array = array.where("#{search_column} like :search", search: "%#{sSearch}%") if sSearch.present?
    array
  end

  def self.to_csv
    column_names = ['code', 'name', 'unit', 'description']
    CSV.generate do |csv|
      csv << column_names.map { |c| self.human_attribute_name(c) }
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
end
