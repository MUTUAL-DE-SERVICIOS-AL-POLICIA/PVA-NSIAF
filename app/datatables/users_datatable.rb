class UsersDatatable
  delegate :current_user, :params, :link_to, :link_to_if, :content_tag, :links_actions, :data_link, :type_status, :img_status, :title_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: current_user.is_super_admin? ? data_admin : data
    }
  end

private

  def data_admin
    array.map do |user|
      [
        user.name,
        user.username,
        I18n.t(user.role, scope: 'users.roles'),
        type_status(user.status),
        links_actions(user)
      ]
    end
  end

  def data
    array.map do |user|
      [
        user.code,
        user.name,
        user.title,
        user.ci,
        user.email,
        user.username,
        user.phone,
        user.mobile,
        link_to_if(user.department, user.department_code, user.department, title: user.department_name),
        type_status(user.status),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), user, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, user], class: 'btn btn-primary btn-sm') + ' ' +
        link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(user.status)}") + title_status(user.status), '#', class: 'btn btn-warning btn-sm', data: data_link(user))
      ]
    end
  end
  def array
    @users ||= fetch_array
  end

  def fetch_array
    array = current_user.users.includes(:department).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      type_search = params[:search_column] == 'department' ? 'departments.code' : "users.#{params[:search_column]}"
      array = array.where("#{type_search} like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? User.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = current_user.is_super_admin? ? %w[users.name username role users.status] : %w[users.code users.name title ci email username phone mobile departments.code users.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
