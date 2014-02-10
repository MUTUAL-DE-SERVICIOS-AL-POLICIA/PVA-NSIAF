class VersionsDatatable
  delegate :params, :link_to, :content_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Version.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |version|
      [
        version.id,
        version.item_id,
        I18n.l(version.created_at, format: :version),
        I18n.t(version.event, scope: 'versions'),
        version.whodunnit,
        I18n.t(version.item_type.to_s.downcase.singularize, scope: 'activerecord.models')
      ]
    end
  end

  def array
    @accounts ||= fetch_array
  end

  def fetch_array
    array = Version.order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page)
    if params[:sSearch].present?
      array = array.where("item_id like :search", search: "%#{params[:sSearch]}%")
    end
    array
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[id item_id created_at event whodunnit item_type]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
