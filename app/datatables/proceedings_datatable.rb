class ProceedingsDatatable
  delegate :current_user, :params, :link_to, :link_to_if, :content_tag, :links_actions, :data_link, :type_status, :img_status, :title_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Proceeding.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |proceeding|
      [
        proceeding.user_name,
        proceeding.admin_name,
        I18n.t(proceeding.get_type, scope: 'proceedings.type'),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), proceeding, class: 'btn btn-default btn-xs')
      ]
    end
  end

  def array
    @users ||= fetch_array
  end

  def fetch_array
    array = Proceeding.includes(:user, :admin).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      type_search = "proceedings.#{params[:search_column]}"
      case params[:search_column]
      when 'user_id' then type_search = 'users.name'
      when 'admin_id' then type_search = 'admins_proceedings.name'
      end
      array = array.where("#{type_search} like :search", search: "%#{params[:sSearch]}%").references(:user, :admin)
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Proceeding.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[users.name admins_proceedings.name proceeding_type]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
