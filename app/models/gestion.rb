class Gestion < ActiveRecord::Base

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'anio'), h.get_column(self, 'cerrado'), h.get_column(self, 'fecha_cierre')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("anio LIKE ? OR cerrado LIKE ? OR fecha_cierre LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(anio cerrado fecha_cierre)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Department.human_attribute_name(c) }
      all.each do |ufv|
        a = Array.new
        a << ufv.anio
        a << ufv.cerrado
        a << ufv.fecha_cierre
        csv << a
      end
    end
  end

end
