class NoteEntry < ActiveRecord::Base
  default_scope {where(invalidate: false)}

  belongs_to :supplier
  belongs_to :user

  has_many :entry_subarticles
  accepts_nested_attributes_for :entry_subarticles
  has_many :kardexes

  has_paper_trail

  before_save :set_note_entry_date

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

  def get_delivery_note_number
    invoice = ''
    if delivery_note_number.present?
      invoice += "#{delivery_note_number}"
    elsif delivery_note_date.present?
      invoice += "#{I18n.l delivery_note_date, format: :default}"
    end
  end

  def get_invoice_number
    invoice = ''
    if invoice_number.present?
      invoice += "#{invoice_number}"
    elsif invoice_date.present?
      invoice += "#{I18n.l invoice_date, format: :default}"
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

  def change_date_entries
    entry_subarticles.each do |entry|
      entry.set_date_value
      entry.save
    end
  end

  def change_kardexes
    kardexes.each do |kardex|
      kardex.kardex_date = note_entry_date
      kardex.invoice_number = get_invoice_number
      kardex.delivery_note_number = get_delivery_note_number
      kardex.save
    end
  end

  def get_date
    entries = entry_subarticles.map(&:subarticle_id)
    count = entries.count + 1
    entry = EntrySubarticle.where(subarticle_id: entries)[0..-count].last.date
    entry.present? ? (Time.now.to_date - entry - 1).to_i : ""
  end

  # Anula una Nota de Entrada, y también los subartículos asociados al mismo.
  # Es necesario especificar el motivo de la anulación
  def invalidate_note(message="")
    transaction do
      update(invalidate: true, message: message)
      entry_subarticles.invalidate_entries
    end
  end

  private

  def set_note_entry_date
    self.note_entry_date = get_first_date
  end

  def get_first_date
    first_date = Time.now.to_date if note_entry_date.nil?
    if delivery_note_date && invoice_date
      first_date = invoice_date
      if delivery_note_date < invoice_date
        first_date = delivery_note_date
      end
    elsif delivery_note_date
      first_date = delivery_note_date
    elsif invoice_date
      first_date = invoice_date
    end
    first_date.to_date
  end
end
