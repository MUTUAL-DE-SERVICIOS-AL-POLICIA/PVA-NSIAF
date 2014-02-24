class Decline < ActiveRecord::Base
  belongs_to :user

  def self.set_columns
   h = ApplicationController.helpers
   c_names = column_names - %w(id created_at updated_at)
   c_names.map{ |c| h.get_column(self, c) unless c == 'object' }.compact
  end

  def user_name
    user ? user.name : ''
  end
end
