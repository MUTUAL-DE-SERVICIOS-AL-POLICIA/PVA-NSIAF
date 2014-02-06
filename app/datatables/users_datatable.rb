class UsersDatatable
  delegate :params, :link_to, :content_tag, :change_status_user_path, :type_status, :img_status, :title_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

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
        user.department_name,
        type_status(user.status),
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), user, class: 'btn btn-default btn-sm') + ' ' +
        link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, user], class: 'btn btn-primary btn-sm') + ' ' +
        link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(user.status)}") + title_status(user.status), change_status_user_path(user), class: 'btn btn-warning btn-sm', remote: true)
      ]
    end
  end

  def array
    @users ||= fetch_array
  end

  def fetch_array
    array = User.includes(:department).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      array = array.where("users.code like :search or users.name like :search or title like :search or ci like :search or email like :search or username like :search or phone like :search or mobile like :search or departments.name like :search or users.status like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? User.count : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[users.code users.name title ci email username phone mobile departments.name users.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
