class Asset < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'CODIGO' => 'code',
    'DESCRIP' => 'description',
    'CODAUX' => 'auxiliary_id',
    'CODRESP' => 'user_id'
  }

  belongs_to :auxiliary
  belongs_to :user

  validates :code, presence: true, uniqueness: true
  validates :description, :auxiliary_id, :user_id, presence: true

  def auxiliary_name
    auxiliary.present? ? auxiliary.name : ''
  end

  def user_name
    user.present? ? user.name : ''
  end
end
