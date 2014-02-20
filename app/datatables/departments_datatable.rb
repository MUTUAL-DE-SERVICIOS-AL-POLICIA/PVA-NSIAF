class DepartmentsDatatable
  delegate :params, :link_to, :link_to_if, :content_tag, :data_link, :type_status, :img_status, :title_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Department.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |department|
      [
        department.code,
        department.name,
        link_to_if(department.building, department.building_code, department.building, title: department.building_name),
        type_status(department.status),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), department, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, department], class: 'btn btn-primary btn-sm') + ' ' +
        link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(department.status)}") + title_status(department.status), '#', class: 'btn btn-warning btn-sm', data: data_link(department))
      ]
    end
  end

  def array
    @departments ||= fetch_array
  end

  def fetch_array
    array = Department.includes(:building).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      type_search = params[:search_column] == 'building' ? 'buildings.code' : "departments.#{params[:search_column]}"
      array = array.where("#{type_search} like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Department.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[departments.code departments.name buildings.code departments.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
