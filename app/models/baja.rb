class Baja < ActiveRecord::Base
  include Autoincremento
  has_many :assets
  belongs_to :user

  MOTIVOS = [
    'Disposición definitiva de bienes',
    'Hurto, robo o pérdida fortuita',
    'Mermas',
    'Vencimientos, descomposiciones, alteraciones o deterioros',
    'Inutilización',
    'Obsolescencia',
    'Desmantelamiento total o parcial de edificaciones, excepto el terreno que no será dado de baja',
    'Siniestros',
    'Otros'
  ]

  # método que verifica si baja tiene un código.
  def tiene_codigo?
    codigo.present?
  end

  # Método para obtener el siguiente codigo de activo.
  def self.obtiene_siguiente_codigo(fecha)
    fecha = fecha.present? ? fecha : Date.today
    bajas_gestion = Baja.where(fecha: fecha.beginning_of_year..fecha.end_of_year)
    bajas_gestion.empty? ? 1 : bajas_gestion.maximum(:codigo) + 1
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = "baja.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("bajas.fecha LIKE ? OR baja.codigo LIKE ? OR baja.observacion LIKE ? OR baja.motivo LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'codigo'), h.get_column(self, 'documento'), h.get_column(self, 'fecha'), h.get_column(self, 'observacion')]
  end
end
