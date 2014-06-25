class Material < ActiveRecord::Base
  include ManageStatus

  has_many :articles

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, presence: true

  def verify_assignment
    articles.present?
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    array = array.where("#{search_column} like :search", search: "%#{sSearch}%") if sSearch.present?
    array
  end

  def self.to_csv
    columns = %w(code description status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |product|
        a = product.attributes.values_at(*columns)
        a.pop(1)
        a.push(h.type_status(product.status))
        csv << a
      end
    end
  end
end
