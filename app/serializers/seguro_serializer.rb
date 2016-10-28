class SeguroSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :supplier, :user, :numero_contrato, :factura_numero, :factura_autorizacion, :factura_fecha, :fecha_inicio_vigencia, :fecha_fin_vigencia, :baja_logica
  has_many :assets, serializer: AssetSerializer

  def factura_fecha
    object.factura_fecha.to_time.iso8601 if object.factura_fecha.present?
  end

  def fecha_inicio_vigencia
    object.fecha_inicio_vigencia.to_time.iso8601 if object.factura_fecha.present?
  end

  def fecha_fin_vigencia
    object.fecha_fin_vigencia.to_time.iso8601 if object.factura_fecha.present?
  end
end
