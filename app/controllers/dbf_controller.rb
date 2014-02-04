class DbfController < ApplicationController

  # GET /dbf/:model
  def index
  end

  ##
  # POST /dbf/:model/import
  # Importa los datos del archivo DBF dentro de la tabla usuarios.
  def import
    if params[:dbf].present?
      klass = params[:model].classify.safe_constantize
      inserted, nils = klass.import_dbf(params[:dbf])
      redirect_to :back, notice: "#{inserted + nils} total registros. #{inserted} registros insertados. #{nils} registros nulos."
    else
      redirect_to :back, alert: "Especifique un archivo para importar"
    end
  end
end
