class ReportesController < ApplicationController
  # load_and_authorize_resource
  include Fechas

  def kardex
    desde, hasta = get_fechas(params)
    respond_to do |format|
      format.html do
        render nothing: true, status: 200, content_type: 'text/html'
      end
      format.pdf do
        # Eliminar archivos PDF existentes
        Dir['tmp/*.pdf'].each { |a| File.delete(a) }
        # Generar los archivos PDF
        Subarticle.where(id: (1..10)).each do |subarticle|
          @subarticle = subarticle

          @transacciones = @subarticle.kardexs(desde, hasta)
          @year = desde.year

          nombre_archivo = "#{subarticle.barcode}_#{view_context.dom_id(subarticle)}.pdf"

          pdf = render_to_string(
            pdf: nombre_archivo,
            layout: 'pdf.html',
            template: 'kardexes/index.html.haml',
            orientation: 'Landscape',
            page_size: 'Letter',
            margin: view_context.margin_pdf,
            header: {html: {template: 'shared/header.pdf.haml'}},
            footer: {html: {template: 'shared/footer.pdf.haml'}}
          )
          save_path = Rails.root.join('tmp', nombre_archivo)
          File.open(save_path, 'wb') do |file|
            file << pdf
          end
        end
        archivo_zip = comprimir_a_zip(desde, hasta)
        send_data(File.open(archivo_zip).read, type: 'application/zip', disposition: 'attachment')
        File.delete archivo_zip if File.exist?(archivo_zip)
      end
    end
  end

  private

    def comprimir_a_zip(desde, hasta)
      nombres_archivos = Dir["tmp/*.pdf"]
      archivo_zip = "tmp/kardex_#{desde}_#{hasta}.zip"
      # Eliminación del ZIP
      File.delete archivo_zip if File.exist?(archivo_zip)

      Zip::File.open(archivo_zip, Zip::File::CREATE) do |zipfile|
        nombres_archivos.each do |filename|
          # Two arguments:
          # - The name of the file as it will appear in the archive
          # - The original file, including the path to find it
          nombre = filename.gsub(/tmp/, 'kardex')
          zipfile.add(nombre, filename)
        end
        zipfile.get_output_stream("README.md") { |os| os.write "Kardexes desde #{desde} hasta #{hasta}" }
      end
      archivo_zip
    end
end
