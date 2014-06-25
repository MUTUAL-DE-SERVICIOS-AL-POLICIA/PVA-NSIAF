class Subarticle < ActiveRecord::Base
  include ManageStatus

  belongs_to :article

  def article_code
    article.present? ? article.code : ''
  end

  def article_name
    article.present? ? article.description : ''
  end

  def verify_assignment
    false
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description'), h.get_column(self, 'unit'), h.get_column(self, 'article')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:article).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      type_search = search_column == 'article' ? 'articles.description' : "subarticles.#{search_column}"
      array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
    end
    array
  end

  def self.to_csv
    columns = %w(code description unit article status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |subarticle|
        a = subarticle.attributes.values_at(*columns)
        a.pop(2)
        a.push(subarticle.article_name, h.type_status(subarticle.status))
        csv << a
      end
    end
  end
end
