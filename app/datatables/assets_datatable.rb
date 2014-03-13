class AssetsDatatable
  delegate :current_user, :params, :link_to, :link_to_if, :content_tag, :img_status, :data_link, to: :@view

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
      [
        asset.code,
        asset.description,
        link_to_if(asset.user, asset.user_name, asset.user, title: asset.user_code),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), asset, class: 'btn btn-default btn-xs') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, asset], class: 'btn btn-primary btn-xs') + ' ' + unsubscribe(asset)
      ]
    end
  end

  def array
    @assets ||= fetch_array
  end

  def fetch_array
    Asset.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Asset.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[assets.code description users.name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def unsubscribe(asset)
    if current_user.is_admin?
      url = link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(asset.status)}") + 'Dar baja', '#', class: 'btn btn-warning btn-xs', data: data_link(asset))
    end
    url || ''
  end
end
