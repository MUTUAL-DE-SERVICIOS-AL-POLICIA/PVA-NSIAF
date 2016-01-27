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

  desc "Cargado los activos desde un ODS"
  task :activos, [:documento] => [:environment] do |t, args|
    unless args[:documento].present?
      puts "Es necesario especificar un parámetro con la ubicación del archivo .ODS"
      next # http://stackoverflow.com/a/2316518/1174245
    end

    file_path = args[:documento]
    s = Roo::OpenOffice.new(file_path)

    first_row = s.first_row
    last_row = s.last_row

    m = a = b = nil

    (first_row..last_row).each_with_index do |r, i|
      if i > 0
        row = s.row(r)
        elemento = {
          code: row[1].to_i,
          # description: "#{row[4]} #{row[5]} #{row[6]} #{row[7]} #{row[8]} #{row[9]} SN/#{row[10]}".squish,
          detalle: "#{row[4]}".squish,
          medidas: "#{row[5]}".squish,
          material: "#{row[6]}".squish,
          color: "#{row[7]}".squish,
          marca: "#{row[8]}".squish,
          modelo: "#{row[9]}".squish,
          serie: "#{row[10]}".squish,
          proceso: row[1].to_i,
          observaciones: "Factura: #{row[11]}\r\nTotal factura: #{row[12]}\r\nProveedor: #{row[13]}\r\nTeléfono: #{row[14]}\r\nCelular: #{row[15]}",
          auxiliary_id: 1,
          barcode: row[1].to_i,
          status: "1",
          state: 1,
          user_id: 2,
          precio: row[3].to_f,
          created_at: row[2]
        }

        activo = Asset.new(elemento)
        activo.save(validate: false)
        puts "#{i}. #{activo.attributes.to_json}"
      end
    end
  end
end
