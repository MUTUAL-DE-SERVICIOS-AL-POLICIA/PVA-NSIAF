# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user = { name: 'Admin', username: 'admin', email: 'admin@adsib.gob.bo', password: 'demo123', role: 'super_admin' }
u = User.find_by_username('admin')
unless u.present?
  u = User.new(user)
  u.save!(validate: false)
  puts "User '#{u.username}' created."
end

if BarcodeStatus.count() == 0
  status = [
    {status: 0, description: 'Libre'},
    {status: 1, description: 'En uso'},
    {status: 2, description: 'Eliminado'}
  ]
  BarcodeStatus.create!(status)
  puts "#{BarcodeStatus.count()} estados adicionados"
end

unless Procedimiento.find_by_metodo("alerta_sin_seguro_vigente").present?
  #-1.Introduciendo el procedimiento para verificar si existen activos sin seguro vigente.
  procedimiento =
    Procedimiento.create!(
      { clase: "Asset",
        metodo: "alerta_sin_seguro_vigente",
        descripcion: "Método para verificar si existen activos sin un seguro vigente"})
  Alerta.create(
    { procedimiento_id: procedimiento.id,
      mensaje: "Existen activos sin seguro!",
      tipo: "danger",
      clase: "Asset",
      controlador: "assets",
      accion: "index"})
end

unless Procedimiento.find_by_metodo("alerta_10_dias_expiracion").present?
  #-1.Introduciendo el procedimiento para verificar si existen activos sin seguro vigente.
  procedimiento =
    Procedimiento.create!(
      { clase: "Seguro",
        metodo: "alerta_10_dias_expiracion",
        descripcion: "Método para verificar la existencia de activos con un seguro que va expirar dentro de 10 dias o menos."})
  Alerta.create(
    { procedimiento_id: procedimiento.id,
      mensaje: "Existen activos con un seguro que expirará dentro de 10 dias o menos.",
      tipo: "warning",
      clase: "Seguro",
      controlador: "assets",
      accion: "index"})
end
