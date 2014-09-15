class Version < PaperTrail::Version
  def item_code
    item.present? ? (item.code || item.try(:username)) : ''
  end

  def item_name
    item.present? ? (%w(Material Article Subarticle).include?(item_type) ? item.description : item.name) : ''
  end

  def whodunnit_code
    user = whodunnit_obj
    user.present? ? (user.username || user.name) : ''
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
   column_names.map{ |c| h.get_column(self, c) unless c == 'object' || c == 'active' }.compact
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user)
    array = order("#{sort_column} #{sort_direction}")
    array = array.joins('LEFT OUTER JOIN users ON users.id = versions.whodunnit').where("versions.active = ? AND users.role like ?", true, current_user.role) unless current_user.is_super_admin?
    array = array.page(page).per_page(per_page) if per_page.present?
    array
  end

  def self.to_csv
    column_names = ['id', 'item_id', 'created_at', 'event', 'whodunnit', 'item_type']
    CSV.generate do |csv|
      csv << column_names.map { |c| Version.human_attribute_name(c) }
      self.all.each do |version|
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

  def self.active_false(ids)
    where(id: ids).update_all(active: false)
  end
end
