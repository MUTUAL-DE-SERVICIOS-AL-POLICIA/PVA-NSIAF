class Asset < ActiveRecord::Base
  belongs_to :auxiliary
  belongs_to :user

  validates :code, presence: true, uniqueness: true
  validates :description, presence: true

  def auxiliary_name
    auxiliary.present? ? auxiliary.name : ''
  end

  def user_name
    user.present? ? user.name : ''
  end
end
