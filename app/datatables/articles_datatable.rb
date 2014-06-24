class ArticlesDatatable
  delegate :params, :link_to_if, :type_status, :links_actions, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Article.count,
      iTotalDisplayRecords: array.total_entries,
      aaData: data
    }
  end

private

  def data
    array.map do |article|
      [
        article.code,
        article.description,
        link_to_if(article.material, article.material_name, article.material, title: article.material_code),
        type_status(article.status),
        links_actions(article)
      ]
    end
  end

  def array
    @articles ||= fetch_array
  end

  def fetch_array
    Article.array_model(sort_column, sort_direction, page, per_page, params[:sSearch], params[:search_column])
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i < 0 ? Article.count + 1 : params[:iDisplayLength].to_i
  end

  def sort_column
    columns = %w[articles.code articles.description materials.description articles.status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
