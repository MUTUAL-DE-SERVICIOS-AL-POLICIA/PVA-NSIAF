class Asset < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog

  CORRELATIONS = {
    'CODIGO' => 'code',
    'DESCRIP' => 'description'
  }

  belongs_to :auxiliary
  belongs_to :user

  with_options if: :is_not_migrate? do |m|
    m.validates :code, presence: true, uniqueness: { scope: [:auxiliary_id, :user_id] }
    m.validates :description, :auxiliary_id, :user_id, presence: true
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: { scope: [:auxiliary_id, :user_id] }
    m.validates :description, presence: true
  end

  has_paper_trail

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

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    asset = { is_migrate: true }
    CORRELATIONS.each do |origin, destination|
      asset.merge!({ destination => record[origin] })
    end
    a = Auxiliary.find_by_code(record['CODAUX'])
    u = User.joins(:department).where(code: record['CODRESP'], departments: { code: record['CODOFIC'] }).take
    asset.present? && new(asset.merge!({ auxiliary: a, user: u })).save
  end
end
