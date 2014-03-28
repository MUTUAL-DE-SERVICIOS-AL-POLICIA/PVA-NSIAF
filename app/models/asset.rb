class Asset < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODIGO' => 'code',
    'DESCRIP' => 'description'
  }

  belongs_to :account
  belongs_to :auxiliary
  belongs_to :user

  has_many :asset_proceedings
  has_many :proceedings, through: :asset_proceedings

  with_options if: :is_not_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, :auxiliary_id, :user_id, presence: true
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, presence: true
  end

  has_paper_trail

  def self.search_by(account_id, auxiliary_id)
    if auxiliary_id.present?
      assets = includes(:user).where(auxiliary_id: auxiliary_id)
    elsif account_id.present?
      assets = includes(:user).where(account_id: account_id)
    else
      assets = self.none
    end
  end

  def auxiliary_code
    auxiliary.present? ? auxiliary.code : ''
  end

  def auxiliary_name
    auxiliary.present? ? auxiliary.name : ''
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
    [h.get_column(self, 'code'), h.get_column(self, 'description'), h.get_column(self, 'user')]
  end

  def verify_assignment
    false
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, status)
    status = '1' if status != '0'
    array = includes(:user).order("#{sort_column} #{sort_direction}").where(status: status)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      type_search = search_column == 'user' ? 'users.name' : "assets.#{search_column}"
      array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
    end
    array
  end

  def self.to_csv
    columns = %w(code description user)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |asset|
        a = asset.attributes.values_at(*columns)
        a.pop
        a.push(asset.user_name)
        csv << a
      end
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
end
