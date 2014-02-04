class Auxiliary < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'CODAUX' => 'code',
    'NOMAUX' => 'name',
    'CODCONT' => 'account_id'
  }

  belongs_to :account

  validates :code, presence: true, uniqueness: true
  validates :name, :account_id, presence: true

  def account_name
    account.present? ? account.name : ''
  end
end
