class Auxiliary < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'CODAUX' => 'code',
    'NOMAUX' => 'name'
  }

  belongs_to :account

  validates :code, presence: true, uniqueness: { scope: :account_id }
  validates :name, :account_id, presence: true

  def account_code
    account.present? ? account.code : ''
  end

  def account_name
    account.present? ? account.name : ''
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
end
