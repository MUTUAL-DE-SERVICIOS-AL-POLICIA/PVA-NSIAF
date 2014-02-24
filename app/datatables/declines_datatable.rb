class DeclinesDatatable
  delegate :params, :link_to_if, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Decline.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |decline|
      [
        decline.asset_code,
        decline.account_code,
        decline.auxiliary_code,
        decline.department_code,
        decline.user_code,
        decline.description,
        decline.reason,
        link_to_if(decline.user, decline.user_name, decline.user, title: decline.user_code)
      ]
    end
  end

  def array
    @declines ||= fetch_array
  end

  def fetch_array
    array = Decline.includes(:user).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      type_search = params[:search_column] == 'user_id' ? 'users.name' : "declines.#{params[:search_column]}"
      array = array.where("#{type_search} like :search", search: "%#{params[:sSearch]}%").references(:user)
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Decline.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[asset_code account_code auxiliary_code department_code user_code description reason users.name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
