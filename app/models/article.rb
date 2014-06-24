class Article < ActiveRecord::Base
  include ManageStatus

  belongs_to :material

  def material_code
    material.present? ? material.code : ''
  end

  def material_name
    material.present? ? material.description : ''
  end

  def verify_assignment
    false
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

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description'), h.get_column(self, 'material')]
  end
end
