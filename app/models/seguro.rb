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

  def self.vigentes(fecha_actual = nil)
    fecha_actual = Date.today unless fecha_actual.present?
    self.activos.where("seguros.fecha_inicio_vigencia <= :fecha_inicio AND seguros.fecha_fin_vigencia >= :fecha_fin", fecha_inicio: fecha_actual, fecha_fin: fecha_actual )
  end

  def expiracion_a_dias(nro_dias)
    fecha_inicio_alerta = fecha_fin_vigencia - nro_dias
    Date.today >= fecha_inicio_alerta
  end

end
