class UsersDatatable
  delegate :params, :link_to, :content_tag, :change_status_user_path, :type_status, :title_status, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: users.total_entries,
      aaData: data
    }
  end

private

  def data
    users.map do |user|
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
        link_to(content_tag(:span, "Ver", class: 'glyphicon glyphicon-eye-open'), user, class: 'btn btn-primary') + ' ' +
        link_to(content_tag(:span, "Editar", class: 'glyphicon glyphicon-edit'), [:edit, user], class: 'btn btn-primary') + ' ' +
        link_to(content_tag(:span, title_status(user.status), class: "glyphicon #{'glyphicon-remove' if user.status == '1'}"), change_status_user_path(user), class: 'btn btn-warning', remote: true)
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    users = User.includes(:department).order("#{sort_column} #{sort_direction}")
    users = users.page(page).per_page(per_page)
    if params[:sSearch].present?
      users = users.where("name like :search", search: "%#{params[:sSearch]}%")
    end
    users
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 15
  end

  def sort_column
    columns = %w[code name title ci email username phone mobile departments.name status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
