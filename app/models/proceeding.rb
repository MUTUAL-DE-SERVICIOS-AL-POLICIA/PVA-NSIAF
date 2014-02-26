class Proceeding < ActiveRecord::Base
  PROCEEDING_TYPE = {
    'E' => 'assignation',
    'D' => 'devolution'
  }

  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :asset_proceedings
  has_many :assets, through: :asset_proceedings

  after_create :update_assignations

  def self.set_columns
   h = ApplicationController.helpers
   c_names = column_names - %w(id created_at updated_at proceeding_type)
   c_names.map{ |c| h.get_column(self, c) unless c == 'object' }.compact
  end

  def user_name
    user ? user.name : ''
  end

  def admin_name
    admin ? admin.name : ''
  end

  def get_type
    PROCEEDING_TYPE[proceeding_type]
  end

  private

  def update_assignations
    assets.update_all(user_id: self.user_id)
  end
end
