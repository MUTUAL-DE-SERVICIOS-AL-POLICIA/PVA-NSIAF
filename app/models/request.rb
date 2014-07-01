class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :subarticle_requests
  has_many :subarticles, through: :subarticle_requests
  accepts_nested_attributes_for :subarticle_requests

  def user_name
    user.present? ? user.name : ''
  end

  def user_title
    user.present? ? user.title : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'id'), h.get_column(self, 'created_at'), h.get_column(self, 'name'), h.get_column(self, 'title')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, delivered)
    array = joins(:user).where(delivered: delivered).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(name title).include?(search_column) ? "users.#{search_column}" : "requests.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")#.references(:user)
      else
        array = array.where("requests.id LIKE ? OR requests.created_at LIKE ? OR users.name LIKE ? OR users.title LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(id created_at name title)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |request|
        a = request.attributes.values_at(*columns)
        a.pop(3)
        a.push(I18n.l(request.created_at, format: :version))
        a.push(request.user_name)
        a.push(request.user_title)
        csv << a
      end
    end
  end
end
