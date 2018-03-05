class Baja < ActiveRecord::Base
  include Autoincremento
  has_many :assets
  belongs_to :user

  # método que verifica si baja tiene un código.
  def tiene_codigo?
    codigo.present?
  end

  # Método para obtener el siguiente codigo de activo.
  def self.obtiene_siguiente_codigo
    Baja.all.empty? ? 1 : Baja.maximum(:codigo) + 1
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    orden = "#{sort_column} #{sort_direction}"
    case sort_column
    when "bajas.codigo"
      orden += ", bajas.codigo #{sort_direction}"
    when "bajas.fecha"
      orden += ", bajas.fecha #{sort_direction}"
    end
    array = joins(:user, :supplier).order(orden)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(users suppliers).include?(search_column) ? "#{search_column}.name" : "baja.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("bajas.factura_fecha LIKE ? OR ingresos.numero LIKE ? OR ingresos.factura_numero LIKE ? OR suppliers.name LIKE ? OR users.name LIKE ? OR ingresos.total LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'codigo'), h.get_column(self, 'documento'), h.get_column(self, 'fecha'), h.get_column(self, 'observacion')]
  end
end
