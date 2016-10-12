class ActivoSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :codigo, :factura, :fecha, :descripcion, :cuenta, :precio

  def id
    object.id
  end

  def codigo
    object.code
  end

  def factura
    object.nro_factura
  end

  def fecha
     I18n.l(object.ingreso_fecha) if object.ingreso_fecha
  end

  def descripcion
    object.description
  end

  def cuenta
    object.account_name
  end

  def precio
    object.precio
  end

end
