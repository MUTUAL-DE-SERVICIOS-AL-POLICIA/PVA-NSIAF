class AssetsDatatable
  delegate :params, :link_to, :link_to_if, :content_tag, to: :@view

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
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), asset, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, asset], class: 'btn btn-primary btn-sm')
      ]
    end
  end

  def array
    @assets ||= fetch_array
  end

  def fetch_array
    array = Asset.includes(:user).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      if params[:search_column] == 'user'
        type_search = 'users.name'
      else
        type_search = "assets.#{params[:search_column]}"
      end
      array = array.where("#{type_search} like :search", search: "%#{params[:sSearch]}%")
    end
    array
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
end
