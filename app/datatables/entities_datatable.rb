class EntitiesDatatable
  delegate :params, :link_to, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Entity.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |entity|
      [
        entity.code,
        entity.name,
        entity.acronym,
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), entity, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, entity], class: 'btn btn-primary btn-sm')
      ]
    end
  end

  def array
    @entities ||= fetch_array
  end

  def fetch_array
    array = Entity.order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      array = array.where("#{params[:search_column]} like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Entity.count : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[code name acronym]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
