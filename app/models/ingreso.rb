class Ingreso < ActiveRecord::Base
  belongs_to :supplier
  has_many :assets
  belongs_to :user

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = joins(:user, :supplier).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(users suppliers).include?(search_column) ? "#{search_column}.name" : "ingresos.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("ingresos.numero LIKE ? OR suppliers.name LIKE ? OR users.name LIKE ? OR ingresos.total LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'numero'), h.get_column(self, 'suppliers'), h.get_column(self, 'users'), h.get_column(self, 'total'), h.get_column(self, 'nota_entrega_fecha')]
  end

  def supplier_name
    supplier.present? ? supplier.name : ''
  end

  def supplier_nit
    supplier.present? ? supplier.nit : ''
  end

  def user_name
    user.present? ? user.name : ''
  end
end
