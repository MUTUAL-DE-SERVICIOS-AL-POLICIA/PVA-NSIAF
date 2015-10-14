FactoryGirl.define do
  factory :seguro do
    supplier ""
    user ""
    numero_contrato "MyString"
    factura_numero "MyString"
    factura_autorizacion "MyString"
    factura_fecha "2016-10-14"
    fecha_inicio_validez "2016-10-14"
    fecha_fin_validez "2016-10-14"
    baja_logica false
  end

end
