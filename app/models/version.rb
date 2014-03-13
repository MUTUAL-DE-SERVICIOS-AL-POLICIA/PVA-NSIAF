class Version < PaperTrail::Version
  def item_code
    item.present? ? (item.code || item.try(:username)) : ''
  end

  def item_name
    item.present? ? item.name : ''
  end

  def whodunnit_code
    user = whodunnit_obj
    user.present? ? (user.code || user.username || user.name) : ''
  end

  def whodunnit_name
    user = whodunnit_obj
    user.present? ? user.name : ''
  end

  def whodunnit_obj
    User.find_by_id(whodunnit)
  end

  def self.set_columns
   h = ApplicationController.helpers
   column_names.map{ |c| h.get_column(self, c) unless c == 'object' }.compact
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
    end
    array
  end

  def self.to_csv(column_names)
    CSV.generate do |csv|
      csv << column_names.map { |c| Version.human_attribute_name(c) }
      all.each do |version|
        a = Array.new
        a << version.id
        a << version.item_code
        a << I18n.l(version.created_at, format: :version)
        a << I18n.t(version.event, scope: 'versions')
        a << version.whodunnit_name
        a << I18n.t(version.item_type.to_s.downcase.singularize, scope: 'activerecord.models')
        csv << a
      end
    end
  end
end
