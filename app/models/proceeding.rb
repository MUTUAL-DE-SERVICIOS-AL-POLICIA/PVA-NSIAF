class Proceeding < ActiveRecord::Base
  PROCEEDING_TYPE = {
    'E' => 'assignation',
    'D' => 'devolution'
  }

  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :asset_proceedings
  has_many :assets, through: :asset_proceedings

  def user_name
    user ? user.name : ''
  end

  def admin_name
    admin ? admin.name : ''
  end
end
