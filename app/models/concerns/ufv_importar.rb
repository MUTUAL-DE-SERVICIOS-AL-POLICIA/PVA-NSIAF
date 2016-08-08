require 'nokogiri'
require 'open-uri'

module UfvImportar
  extend ActiveSupport::Concern

  module ClassMethods
    # Descargar e importar si la fecha es menor
    def descargar_e_importar_si
      desde = Ufv.order(:fecha).last.fecha rescue Rails.application.secrets.ufv_desde.to_date
      if desde < Date.today
        hasta = desde + 1.month
        descargar_e_importar(desde, hasta)
      else
        puts "La fecha #{desde.to_s(:db)} tiene que ser menor a #{Date.today.to_s(:db)}"
      end
    end

    # Permite realizar la descarga de UFVs desde la página web del Banco Central
    # de Bolivia y posteriormente importarlo a la tabla `ufvs`
    def descargar_e_importar(desde = nil, hasta = nil)
      if !desde.present? && !hasta.present?
        # Rango de fechas que se consultará
        desde = Ufv.order(:fecha).last.fecha rescue Rails.application.secrets.ufv_desde.to_date
        hasta = desde + 1.month
      end

      # Conectarse a la página web del BCB
      ufvs_html = obtener_ufv_bcb(desde, hasta)

      # Parsing del contenido
      ufvs_html.css('table tr.listas-fila1, table tr.listas-fila2').each do |fila|
        fecha_str = convertir_fecha(fila.css('td:nth-child(2)').text.strip)
        ufv = {
          fecha: Date.strptime(fecha_str, '%d de %m %Y'),
          valor: fila.css('td:nth-child(3)').text.strip.sub(',', '.')
        }
        Ufv.find_or_create_by!(fecha: ufv[:fecha], valor: ufv[:valor])
      end
    end

    private

      # Convierte la fecha a números para el mes: 31 de Enero 2016
      def convertir_fecha(fecha)
        meses = %w(enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre)
        fecha = fecha.split
        fecha[2] = meses.index(fecha[2].downcase) + 1
        fecha.join(' ')
      end

      # Obtener la página HTML con los UFVs en un rango de fechas: desde - hasta
      def obtener_ufv_bcb(d, h)
        url_base = 'https://www.bcb.gob.bo/librerias/indicadores/ufv/gestion.php'
        url_params = [
          "sdd=#{d.day}&smm=#{d.month}&saa=#{d.year}", # desde
          "Button=++Ver++", # botón
          "reporte_pdf=#{d.strftime('%-m*%-d*%Y')}**#{h.strftime('%-m*%-d*%Y')}*",
          "edd=#{h.day}&emm=#{h.month}&eaa=#{h.year}", # hasta
          "qlist=1"
        ].join('&')
        puts [url_base, url_params].join('?')
        Nokogiri::HTML(open([url_base, url_params].join('?')))
      end
  end
end
