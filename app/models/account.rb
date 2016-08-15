class Account < ActiveRecord::Base
  include ImportDbf, VersionLog
  include Moneda

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name',
    'VIDAUTIL' => 'vida_util',
    'DEPRECIAR' => 'depreciar',
    'ACTUALIZAR' => 'actualizar'
  }

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_many :auxiliaries
  has_many :assets

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("code LIKE ? OR name LIKE ? OR vida_util LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code name vida_util)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |account|
        csv << account.attributes.values_at(*columns)
      end
    end
  end

  def self.con_activos
    joins(auxiliaries: :assets).uniq
  end

  def code_and_name
    "#{code} - #{name}"
  end

  ##
  # BEGIN datos para el reporte resumen de activos fijos ordenado por grupo contable
  def auxiliares_activos(fecha = Date.today)
    activos = Asset.joins(:ingreso).where(auxiliary_id: auxiliaries.ids)
    activos.where('ingresos.factura_fecha <= ?', fecha)
  end

  def cantidad_activos(fecha = Date.today)
    auxiliares_activos(fecha).length
  end

  def costo_historico(fecha = Date.today)
    auxiliares_activos(fecha).costo_historico
  end

  def costo_actualizado_inicial(fecha = Date.today)
    auxiliares_activos(fecha).costo_actualizado_inicial(fecha)
  end

  def depreciacion_acumulada_inicial(fecha = Date.today)
    auxiliares_activos(fecha).depreciacion_acumulada_inicial(fecha)
  end

  def valor_neto_inicial(fecha = Date.today)
    auxiliares_activos(fecha).inject(0) do |suma, activo|
      suma + activo.costo_actualizado_inicial(fecha) - activo.depreciacion_acumulada_inicial(fecha)
    end
  end

  def actualizacion_gestion(fecha = Date.today)
    auxiliares_activos(fecha).actualizacion_gestion(fecha)
  end

  def costo_actualizado(fecha = Date.today)
    auxiliares_activos(fecha).costo_actualizado(fecha)
  end

  def depreciacion_gestion(fecha = Date.today)
    auxiliares_activos(fecha).depreciacion_gestion(fecha)
  end

  def actualizacion_depreciacion_acumulada(fecha = Date.today)
    auxiliares_activos(fecha).actualizacion_depreciacion_acumulada(fecha)
  end

  def depreciacion_acumulada_total(fecha = Date.today)
    auxiliares_activos(fecha).depreciacion_acumulada_total(fecha)
  end

  def valor_neto(fecha = Date.today)
    auxiliares_activos(fecha).valor_neto(fecha)
  end

  def self.cantidad_activos(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + cuenta.cantidad_activos(fecha)
    end
  end

  def self.costo_historico(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.costo_historico(fecha))
    end
  end

  def self.costo_actualizado_inicial(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.costo_actualizado_inicial(fecha))
    end
  end

  def self.depreciacion_acumulada_inicial(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.depreciacion_acumulada_inicial(fecha))
    end
  end

  def self.valor_neto_inicial(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.valor_neto_inicial(fecha))
    end
  end

  def self.actualizacion_gestion(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.actualizacion_gestion(fecha))
    end
  end

  def self.costo_actualizado(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.costo_actualizado(fecha))
    end
  end

  def self.depreciacion_gestion(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.depreciacion_gestion(fecha))
    end
  end

  def self.actualizacion_depreciacion_acumulada(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.actualizacion_depreciacion_acumulada(fecha))
    end
  end

  def self.depreciacion_acumulada_total(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.depreciacion_acumulada_total(fecha))
    end
  end

  def self.valor_neto(fecha = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.valor_neto(fecha))
    end
  end
  # END datos para el reporte resumen de activos fijos ordenado por grupo contable
  ##
end
