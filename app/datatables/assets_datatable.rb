class AssetsDatatable
  delegate :params, :link_to, :link_to_if, :content_tag, :img_status, :data_link, :links_actions, :current_user, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Asset.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |asset|
      as = []
      as << asset.code
      as << asset.code_old
      as << asset.description
      as << (asset.ingreso_fecha.present? ? I18n.l(asset.ingreso_fecha) : nil)
      as << asset.precio
      as << link_to_if(asset.ingreso, asset.ingreso_proveedor_nombre, asset.ingreso_proveedor)
      as << link_to_if(asset.account, asset.account_name, asset.account)
      as << link_to_if(asset.user, asset.user_name, asset.user, title: asset.user_code)
      as << content_tag(:span, asset.ubicacion_abreviacion, title: asset.ubicacion_detalle)
      as << icono_seguro(asset.seguro_vigente?)
      if asset.status == '0'
        as << (asset.derecognised.present? ? I18n.l(asset.derecognised, format: :version) : '')
      end
      as << links_actions(asset, 'asset')
      as
    end

  end

  # Método que obtiene el ícono que corresponde a los activos con o sin seguro.
  def icono_seguro(seguro_vigente)
    if seguro_vigente
      content_tag(:span, content_tag(:i, '', class: 'fa fa-lock', 'aria-hidden' => 'true'), class: 'pull-right badge badge-success', title: 'Asegurado')
    else
      content_tag(:span, content_tag(:i, '', class: 'fa fa-unlock', 'aria-hidden' => 'true'), class: 'pull-right badge badge-default', title: 'Sin Asegurar')
    end
  end

  def array
    @assets ||= fetch_array
  end

  def fetch_array
    status = @view.url_for == "#{Rails.application.config.action_controller.relative_url_root}/assets" ? '1' : '0'
    Asset.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column], status)
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Asset.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    Asset.columnas[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def unsubscribe(asset)
    if @view.url_for == "#{Rails.application.config.action_controller.relative_url_root}/assets" && asset.user.present? && asset.user.id == current_user.id
      url = link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(asset.status)}"), '#', class: 'btn btn-warning btn-xs', data: data_link(asset), title: 'Dar baja')
    end
    url || ''
  end
end
