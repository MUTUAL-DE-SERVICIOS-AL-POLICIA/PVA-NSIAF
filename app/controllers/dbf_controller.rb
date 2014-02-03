class DbfController < ApplicationController

  # GET /dbf/:model
  def index
  end

  ##
  # POST /dbf/:model/import
  # Importa los datos del archivo DBF dentro de la tabla usuarios.
  def import
    klass = params[:model].classify.safe_constantize
    inserted, nils = klass.import_dbf(params[:dbf])
    redirect_to :back, notice: "#{inserted + nils} total registros. #{inserted} registros insertados. #{nils} registros nulos."
  end
end
