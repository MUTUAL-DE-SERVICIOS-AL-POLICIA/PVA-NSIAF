class NoteEntry < ActiveRecord::Base
  belongs_to :supplier
  has_many :entry_subarticles
  accepts_nested_attributes_for :entry_subarticles
  belongs_to :user

  def supplier_name
    supplier.present? ? supplier.name : ''
  end

  def user_name
    user.present? ? user.name : ''
  end

  def user_title
    user.present? ? user.title : ''
  end

  def note_number(number)
    number.present? ? "##{number}" : ''
  end

  def note_date(date)
    date.present? ? I18n.l(date) : ''
  end

  def get_invoice_number
    invoice = ''
    if delivery_note_number.present?
      invoice += "NE: #{delivery_note_number}"
    elsif delivery_note_date.present?
      invoice += "NE: #{I18n.l delivery_note_date, format: :default}"
    end
    if invoice_number.present?
      invoice += " FACT: #{invoice_number}"
    elsif invoice_date.present?
      invoice += " FACT: #{I18n.l invoice_date, format: :default}"
    end
    invoice.strip
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = joins(:user, :supplier).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(users suppliers).include?(search_column) ? "#{search_column}.name" : "note_entries.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("note_entries.id LIKE ? OR suppliers.name LIKE ? OR users.name LIKE ? OR note_entries.total LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'id'), h.get_column(self, 'suppliers'), h.get_column(self, 'users'), h.get_column(self, 'total'), h.get_column(self, 'delivery_note_date')]
  end

  def self.to_csv
    columns = %w(id suppliers users total delivery_note_date)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |note_entry|
        a = note_entry.attributes.values_at(*columns)
        a.pop(4)
        a.push(note_entry.supplier_name)
        a.push(note_entry.user_name)
        a.push(note_entry.total)
        a.push(note_entry.note_date(note_entry.delivery_note_date))
        csv << a
      end
    end
  end
end
