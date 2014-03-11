class Entity < ActiveRecord::Base
  include ImportDbf

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :acronym, presence: true

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'acronym')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
    end
    array
  end
end
