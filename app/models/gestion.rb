class Gestion < ActiveRecord::Base

  validates :anio, presence: true,
                   uniqueness: true

  # Retorna el año de la gestión actual que es la última gestión que no está cerrada
  def self.actual
    gestion_actual.anio rescue ''
  end

  def self.cerrar_gestion(fecha)
    gestion = find_by(anio: fecha.year)
    gestion.cerrado = true
    gestion.fecha_cierre = DateTime.now
    gestion.save!
  end

  def self.cerrar_gestion_actual
    if self.actual.present?
      # TODO calcular el 31 de diciembre de ese año
      # guardar los resultados en una tabla intermedia
      fecha = Date.strptime(self.actual.to_s, '%Y')
      self.transaction do
        Asset.cerrar_gestion_actual(fecha.end_of_year)
        Gestion.cerrar_gestion(fecha.end_of_year)
      end
    else
      # TODO falta establecer la gestión actual
    end
  end

  def self.gestion_abierto
    where(cerrado: false).order(:anio)
  end

  # Retorna el objeto gestión actual
  def self.gestion_actual
    gestion_abierto.first rescue nil
  end

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
    columns = %w(anio estado fecha_cierre)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Department.human_attribute_name(c) }
      all.each do |ufv|
        a = Array.new
        a << ufv.anio
        a << (ufv.cerrado ? 'Cerrado' : 'Abierto')
        a << ufv.fecha_cierre
        csv << a
      end
    end
  end

  # Verificar si una gestión es la gestión actual
  def gestion_actual?
    Gestion.gestion_actual == self
  end

end
