class Auxiliary < ActiveRecord::Base
  belongs_to :account

  validates :code, presence: true, uniqueness: true
  validates :name, :account_id, presence: true

  def account_name
    account.present? ? account.name : ''
  end
end
