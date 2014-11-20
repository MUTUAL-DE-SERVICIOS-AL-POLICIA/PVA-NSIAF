class SubarticlesDatatable
  delegate :params, :link_to_if, :type_status, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Subarticle.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |subarticle|
      [
        subarticle.code,
        subarticle.description,
        subarticle.unit,
        subarticle.barcode,
        link_to_if(subarticle.article, subarticle.article_name, subarticle.article, title: subarticle.article_code),
        type_status(subarticle.status),
        links_actions(subarticle)
      ]
    end
  end

  def array
    @subarticles ||= fetch_array
  end

  def fetch_array
    Subarticle.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Article.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[subarticles.code subarticles.description subarticles.unit barcode articles.description subarticles.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
