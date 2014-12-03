class Subarticle < ActiveRecord::Base
  include Migrated, ManageStatus, VersionLog

  belongs_to :article
  has_many :subarticle_requests
  has_many :requests, through: :subarticle_requests
  has_many :entry_subarticles
  has_many :kardexes

  with_options if: :is_not_migrate? do |m|
    m.validates :barcode, presence: true, uniqueness: true
    m.validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :description, :unit, :article_id, presence: true
    #m.validates :amount, :minimum, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validate do |subarticle|
      BarcodeStatusValidator.new(subarticle).validate
    end
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, :unit, presence: true
  end

  before_save :check_barcode

  has_paper_trail

  def article_code
    article.present? ? article.code : ''
  end

  def article_name
    article.present? ? article.description : ''
  end

  def verify_assignment
    false
  end

  def stock
    entry_subarticles_exist.sum(:stock)
  end

  # Only entries with stock > 0
  def entry_subarticles_exist
    entry_subarticles.where('stock > 0').order(:created_at)
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description'), h.get_column(self, 'unit'), h.get_column(self, 'barcode'), h.get_column(self, 'article')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:article).order("#{sort_column} #{sort_direction}").references(:article)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == 'article' ? 'articles.description' : "subarticles.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("subarticles.code LIKE ? OR subarticles.description LIKE ? OR subarticles.unit LIKE ? OR articles.description LIKE ? OR subarticles.barcode LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code description unit barcode article status)
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

  def self.get_barcode(barcode)
    where(barcode: barcode)
  end

  def exists_amount?
    entry_subarticles_exist.present?
  end

  def decrease_amount
    if entry_subarticles_exist.length > 0
      entry_subarticle = entry_subarticles_exist.first # FIFO - PEPS
      entry_subarticle.decrease_amount
    end
  end

  def final_kardex
    self.kardexes.final_kardex
  end

  def self.search_subarticle(q)
    where("description LIKE ? AND status = ?", "%#{q}%", 1).map { |s| s.entry_subarticles.first.present? ? { id: s.id, description: s.description, unit: s.unit, code: s.code, stock: s.stock } : nil }.compact
  end

  def check_barcode
    if is_not_migrate?
      bcode = Barcode.find_by_code barcode
      if bcode.present?
        self.barcode = bcode.code
        bcode.change_to_used
      end
    end
  end

  def last_kardex
    kardexes.order(:created_at).last
  end

  def self.search_by(article_id)
    subarticles = []
    subarticles = where(article_id: article_id, status: 1) if article_id.present?
    [['', '--']] + subarticles.map { |d| [d.id, d.description] }
  end
end
