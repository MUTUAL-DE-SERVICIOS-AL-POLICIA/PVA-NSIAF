namespace :db do
  ##
  # Para el caso de los clasificadores públicos en la ADSIB tienen un listado
  # el cual por el momento se importa a la base de datos mediante la tarea
  # que está descrito a continuación.
  # TODO: Lo ideal es tener una interfaz web que permita cargar estos datos a
  # partir de una hoja de cálculo
  # uso: rake db:materiales["/directorio/del/archivo.ods"]
  desc "Cargado de los clasificadores públicos para almacenes"
  task :materiales, [:documento] => [:environment] do |t, args|
    unless args[:documento].present?
      puts "Es necesario especificar un parámetro con la ubicación del archivo .ODS"
      next # http://stackoverflow.com/a/2316518/1174245
    end

    file_path = args[:documento]
    s = Roo::OpenOffice.new(file_path)

    first_row = s.first_row
    last_row = s.last_row

    m = a = b = nil

    (first_row..last_row).each do |r|
      row = s.row(r)
      element = { code: row[1].to_i, description: row[2] }

      case row[0]
      when 'm'
        m = Material.find_by_code(element[:code].to_s)
        unless m.present?
          m = Material.new(element)
          m.save!
          puts "Material adicionado: #{m.code}"
        end
      when 'a'
        a = Article.find_by_code(element[:code].to_s)
        unless a.present?
          a = Article.new(element.merge({material_id: m.id}))
          a.save!
          puts "  Artículo adicionado: #{a.code}"
        end
      when 'i'
        # Ignore when option 'i'
        puts "    Ignorado: #{row.inspect}"
      else
        if !row[1].nil? && row[1] != 'Código'
          b = Subarticle.find_by_code(element[:code].to_s)
          unless b.present?
            b = Subarticle.new(element.merge({article_id: a.id, unit: row[3]}))
            b.save!(validate: false)
          end
        end
      end
    end
  end
end
