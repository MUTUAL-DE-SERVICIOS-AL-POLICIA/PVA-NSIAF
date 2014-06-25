class Article < ActiveRecord::Base
  include ManageStatus

  belongs_to :material
  has_many :subarticles

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, :material_id, presence: true

  def material_code
    material.present? ? material.code : ''
  end

  def material_name
    material.present? ? material.description : ''
  end

  def verify_assignment
    subarticles.present?
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description'), h.get_column(self, 'material')]
  end

   def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:material).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      type_search = search_column == 'material' ? 'materials.description' : "articles.#{search_column}"
      array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
    end
    array
  end

  def self.to_csv
    columns = %w(code description material status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |article|
        a = article.attributes.values_at(*columns)
        a.pop(2)
        a.push(article.material_name, h.type_status(article.status))
        csv << a
      end
    end
  end
end
