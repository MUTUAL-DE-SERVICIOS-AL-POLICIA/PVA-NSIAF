FactoryGirl.define do
  factory :seguro do
    supplier "uno"
    user "usuario"
    numero_contrato "MyString"
    factura_numero "MyString"
    factura_autorizacion "MyString"
    factura_fecha "2016-10-14"
    fecha_inicio_vigencia "2016-10-14"
    fecha_fin_vigencia "2017-10-14"
    baja_logica false
  end

end
