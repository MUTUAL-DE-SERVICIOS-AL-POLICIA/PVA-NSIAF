class Auxiliary < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODAUX' => 'code',
    'NOMAUX' => 'name'
  }

  belongs_to :account
  has_many :assets

  validates :code, presence: true, uniqueness: { scope: :account_id }
  validates :name, :account_id, presence: true

  has_paper_trail ignore: [:status, :updated_at]

  def account_code
    account.present? ? account.code : ''
  end

  def account_name
    account.present? ? account.name : ''
  end

  def verify_assignment
    assets.present?
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    aux = Hash.new
    CORRELATIONS.each do |origin, destination|
      aux.merge!({ destination => record[origin] })
    end
    a = Account.find_by_code(record['CODCONT'])
    a.present? && aux.present? && new(aux.merge!({ account: a })).save
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'account')]
  end
end
