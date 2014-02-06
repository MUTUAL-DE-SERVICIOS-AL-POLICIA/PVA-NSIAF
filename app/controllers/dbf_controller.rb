class DbfController < ApplicationController

  # GET /dbf/:model
  def index
  end

  ##
  # POST /dbf/:model/import
  # Importa los datos del archivo DBF dentro de la tabla usuarios.
  def import
    if check_dbf_file(params[:dbf])
      klass = params[:model].classify.safe_constantize
      inserted, nils = klass.import_dbf(params[:dbf])
      redirect_to :back, notice: "#{inserted + nils} total registros. #{inserted} registros insertados. #{nils} registros nulos."
    else
      redirect_to :back, alert: "Especifique el archivo <b>#{view_context.get_filename(params[:model])}</b> para migrar"
    end
  end

  private

  def check_dbf_file(dbf)
    dbf.present? && is_dbf_file?(dbf)
  end

  def is_dbf_file?(dbf)
    view_context.dbf_mime_types.include?(dbf.content_type) && view_context.get_filename(params[:model]) == dbf.original_filename
  end
end
