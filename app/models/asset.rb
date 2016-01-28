class Asset < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODIGO' => 'code',
    'DESCRIP' => 'description',
    'CODESTADO' => 'state',
    'OBSERV' => 'observation'
  }

  STATE = {
    'Bueno' => '1',
    'Regular' => '2',
    'Malo' => '3'
  }

  belongs_to :account
  belongs_to :auxiliary
  belongs_to :user, counter_cache: true

  has_many :asset_proceedings
  has_many :proceedings, through: :asset_proceedings

  scope :assigned, -> { where.not(user_id: nil) }
  scope :unassigned, -> { where(user_id: nil) }

  with_options if: :is_not_migrate? do |m|
    m.validates :barcode, presence: true, uniqueness: true
    m.validates :code, presence: true, uniqueness: true
    m.validates :detalle, :auxiliary_id, :user_id, :precio, presence: true
    m.validate do |asset|
      BarcodeStatusValidator.new(asset).validate
    end
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, presence: true
  end

  before_save :check_barcode
  before_save :generar_descripcion

  has_paper_trail

  def self.derecognised
    where(status: 0)
  end

  def self.historical_assets(user)
    includes(:user).joins(:asset_proceedings).where(asset_proceedings: {proceeding_id: user.proceeding_ids})
  end

  def auxiliary_code
    auxiliary.present? ? auxiliary.code : ''
  end

  def auxiliary_name
    auxiliary.present? ? auxiliary.name : ''
  end

  def change_barcode_to_deleted
    if self.barcode_was.present? && self.barcode_was != self.barcode
      bc = Barcode.find_by_code barcode_was
      bc.change_to_deleted if bc.present?
    end
  end

  def check_barcode
    if is_not_migrate?
      bcode = Barcode.find_by_code barcode
      if bcode.present?
        self.barcode = bcode.code
        bcode.change_to_used
      end
      change_barcode_to_deleted
    end
  end

  def name
    description
  end

  def user_code
    user.present? ? user.code : ''
  end

  def user_name
    user.present? ? user.name : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description'), h.get_column(self, 'user'), h.get_column(self, 'barcode'), h.get_column(User, 'department')]
  end

  def self.without_barcode
    where("barcode IS NULL OR barcode = ''")
  end

  def self.without_user
    where(user_id: nil)
  end

  def verify_assignment
    false
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, status)
    array = includes(user: :department).order("#{sort_column} #{sort_direction}").where(status: status).references(user: :department)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        if search_column == 'department'
          array = array.where("departments.name like ?", "%#{sSearch}%")
        else
          type_search = search_column == 'user' ? 'users.name' : "assets.#{search_column}"
          array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
        end
      else
         array = array.where("assets.code LIKE ? OR assets.barcode LIKE ? OR assets.description LIKE ? OR users.name LIKE ? OR departments.name LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv(is_low = false)
    columns = %w(code description user)
    columns_title = columns
    columns_title += %w(derecognised) if is_low
    CSV.generate do |csv|
      csv << columns_title.map { |c| self.human_attribute_name(c) }
      all.each do |asset|
        a = asset.attributes.values_at(*columns).compact
        a.push(asset.user_name)
        a.push(I18n.l(asset.derecognised, format: :version)) if asset.derecognised.present?
        csv << a
      end
    end
  end

  def self.total_historico
    all.sum(:precio)
  end

  def derecognised_date
    update_attribute(:derecognised, Time.now)
  end

  def get_state
    case state
    when 1 then 'Bueno'
    when 2 then 'Regular'
    when 3 then 'Malo'
    end
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    asset = { is_migrate: true }
    CORRELATIONS.each do |origin, destination|
      asset.merge!({ destination => record[origin] })
    end
    ac = Account.find_by_code(record['CODCONT'])
    ax = Auxiliary.joins(:account).where(code: record['CODAUX'], accounts: { code: record['CODCONT'] }).take
    u = User.joins(:department).where(code: record['CODRESP'], departments: { code: record['CODOFIC'] }).take
    asset.present? && new(asset.merge!({ account: ac, auxiliary: ax, user: u })).save
  end

  def generar_descripcion
    descripcion = []
    descripcion << detalle
    descripcion << medidas
    descripcion << material
    descripcion << color
    descripcion << marca
    descripcion << modelo
    descripcion << serie
    self.description = descripcion.join(' ').squish
  end
end
