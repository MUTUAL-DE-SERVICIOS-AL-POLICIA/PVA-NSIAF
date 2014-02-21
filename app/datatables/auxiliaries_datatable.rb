class AuxiliariesDatatable
  delegate :params, :link_to, :link_to_if, :content_tag, :data_link, :type_status, :img_status, :title_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Auxiliary.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |auxiliary|
      [
        auxiliary.code,
        auxiliary.name,
        link_to_if(auxiliary.account, auxiliary.account_code, auxiliary.account, title: auxiliary.account_name),
        type_status(auxiliary.status),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), auxiliary, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, auxiliary], class: 'btn btn-primary btn-sm') + ' ' +
        link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(auxiliary.status)}") + title_status(auxiliary.status), '#', class: 'btn btn-warning btn-sm', data: data_link(auxiliary))
      ]
    end
  end

  def array
    @auxiliaries ||= fetch_array
  end

  def fetch_array
    array = Auxiliary.includes(:account).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      type_search = params[:search_column] == 'account' ? 'accounts.code' : "auxiliaries.#{params[:search_column]}"
      array = array.where("#{type_search} like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Auxiliary.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[auxiliaries.code auxiliaries.name accounts.code status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
