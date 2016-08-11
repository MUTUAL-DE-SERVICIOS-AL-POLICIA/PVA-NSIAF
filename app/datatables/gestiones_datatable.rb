class GestionesDatatable
  delegate :params, :links_actions, :format_date, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Gestion.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |gestion|
      [
        gestion.anio,
        (gestion.cerrado ? 'SI' : 'NO'),
        format_date(gestion.fecha_cierre),
        links_actions(gestion, 'gestion')
      ]
    end
  end

  def array
    @entities ||= fetch_array
  end

  def fetch_array
    Gestion.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Gestion.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[anio cerrado fecha_cierre]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
