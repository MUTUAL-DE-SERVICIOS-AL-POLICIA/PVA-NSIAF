class SeguroSerializer < ActiveModel::Serializer
  attributes :id, :supplier, :user, :numero_contrato, :factura_numero, :factura_autorizacion, :factura_fecha, :fecha_inicio_validez, :fecha_fin_validez, :baja_logica
end
