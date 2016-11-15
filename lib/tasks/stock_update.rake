namespace :db do
  ##
  # Esta tarea es para igualar las sumatoria de entry_subarticles y coincida
  # con el stock disponible del subarticulo, esto para los subarticulos que
  # tengan esta diferencia.
  # uso: rake db:stock_update
  desc 'Actualizando los subarticulos que tengan la diferencia en el stock y la sumatoria de entry_subarticles'
  task :stock_update do
    archivo = File.new('stock_update.txt', 'w')
    texto = ''
    cantidad_stock_mayor = 0
    cantidad_stock_menor = 0
    cantidad_stock_cero = 0
    errores = 0
    subarticulos_con_diferencia = Subarticle.all.select{ |s| s.stock != s.entry_subarticles_exist.sum(:stock) }
    texto = "Cantidad de subarticulos que serán afectados: #{subarticulos_con_diferencia.size}"
    mostrar_escribir(archivo, texto)
    subarticulos_con_diferencia.each_with_index do |subarticulo, i|
      texto = "#{i + 1}. -------------------------------"
      mostrar_escribir(archivo, texto)
      texto = "subarticle_id: #{subarticulo.id}"
      mostrar_escribir(archivo, texto)
      texto = "Stock: #{subarticulo.stock}"
      mostrar_escribir(archivo, texto)
      texto = "Sumatoria entry_subarticles: #{subarticulo.entry_subarticles_exist.sum(:stock)}"
      mostrar_escribir(archivo, texto)
      texto = "Transacciones: #{subarticulo.transacciones.pluck(:cantidad)}"
      mostrar_escribir(archivo, texto)
      texto = "Entry_subarticles: #{subarticulo}"
      mostrar_escribir(archivo, texto)
      texto = "Cantidad entry_subarticles: #{subarticulo.entry_subarticles_exist.size}"
      mostrar_escribir(archivo, texto)
      if subarticulo.stock > subarticulo.entry_subarticles_exist.sum(:stock)
        cantidad_stock_mayor += 1
      else
        cantidad_stock_menor += 1
      end
      cantidad_stock_cero += 1 if subarticulo.stock.zero?
    end
    texto = '=================================='
    mostrar_escribir(archivo, texto)
    texto = "Stock mayor sumatoria: #{cantidad_stock_mayor}"
    mostrar_escribir(archivo, texto)
    texto = "Stock menor sumatoria: #{cantidad_stock_menor}"
    mostrar_escribir(archivo, texto)
    texto = "Stock igual a cero: #{cantidad_stock_cero}"
    mostrar_escribir(archivo, texto)
    texto = "Errores: #{errores}"
    mostrar_escribir(archivo, texto)
    archivo.close
  end

  # Metodo que muestra y guarda un texto en un archivo.
  def mostrar_escribir(archivo, texto)
    puts texto
    archivo.puts(texto)
  end
end
