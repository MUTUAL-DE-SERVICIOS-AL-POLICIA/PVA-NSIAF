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
        asset.user_name,
        link_to_if(asset.auxiliary, asset.auxiliary_code, asset.auxiliary, title: asset.auxiliary_name),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), asset, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, asset], class: 'btn btn-primary btn-sm')
      ]
    end
  end

  def array
    @assets ||= fetch_array
  end

  def fetch_array
    array = Asset.includes(:auxiliary, :user).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      array = array.where("assets.code like :search or description like :search or users.name like :search or auxiliaries.code like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Asset.count : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[assets.code description users.name auxiliaries.code]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
