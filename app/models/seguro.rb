class Seguro < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :supplier, dependent: :destroy
  has_and_belongs_to_many :assets

  validates :supplier_id, :user_id, :factura_numero, :factura_autorizacion,
            :factura_fecha, :fecha_inicio_vigencia, :fecha_fin_vigencia,
            presence: true

  scope :activos, -> { where(baja_logica: false) }

  def proveedor_nombre
    supplier.present? ? supplier.name : ''
  end

  def proveedor_nit
    supplier.present? ? supplier.nit : ''
  end

  def proveedor_telefono
    supplier.present? ? supplier.telefono : ''
  end

  def usuario_nombre
    user.present? ? user.name : ''
  end

  def vigente?(fecha_actual = Date.today)
    fecha_inicio_vigencia <= fecha_actual && fecha_fin_vigencia >= fecha_actual
  end

  def estado
    vigente? ? "VIGENTE" : "NO VIGENTE"
  end

  def cantidad_activos
    "#{assets.size}"
  end

  def self.vigentes(fecha_actual = Date.today)
    self.activos.where("fecha_inicio_vigencia <= ?", fecha_actual)
                .where("fecha_fin_vigencia >= ?", fecha_actual )
  end

  def dias_para_expiracion(fecha_actual = Date.today)
    (fecha_fin_vigencia - fecha_actual).to_i
  end

  def expiracion_a_dias(nro_dias)
    fecha_inicio_alerta = fecha_fin_vigencia - nro_dias
    Date.today >= fecha_inicio_alerta
  end

  def self.alerta_30_dias_expiracion
    self.vigentes.each do |s|
      return true if s.expiracion_a_dias(30) && s.assets.present?
    end
    false
  end

  def self.alerta_10_dias_expiracion
    self.vigentes.each do |s|
      return true if s.expiracion_a_dias(10) && s.assets.present?
    end
    false
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    orden = "#{sort_column} #{sort_direction}"
    array = joins(:supplier).order(orden)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == "suppliers" ? "#{search_column}.name" : "seguros.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("seguros.numero_contrato LIKE ?", "%#{sSearch}%")
                     .or(array.where("seguros.factura_numero LIKE ?", "%#{sSearch}%"))
                     .or(array.where("suppliers.name LIKE ?", "%#{sSearch}%"))
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'numero_contrato'), h.get_column(self, 'factura_numero'), h.get_column(self, 'suppliers')]
  end

  def self.to_csv(is_low = false)
    columns_title = %w(numero_contrato suppliers numero_factura fecha_inicio_vigencia fecha_fin_vigencia estado nro_activos )
    CSV.generate do |csv|
      csv << columns_title.map { |c| self.human_attribute_name(c) }
      all.each do |seguro|
        a = []
        a.push(seguro.numero_contrato)
        a.push(seguro.proveedor_nombre)
        a.push(seguro.factura_numero)
        a.push(seguro.fecha_inicio_vigencia.present? ? I18n.l(seguro.fecha_inicio_vigencia) : '')
        a.push(seguro.fecha_fin_vigencia.present? ? I18n.l(seguro.fecha_fin_vigencia) : '')
        a.push(seguro.estado)
        a.push(seguro.cantidad_activos)
        csv << a
      end
    end
  end
end
