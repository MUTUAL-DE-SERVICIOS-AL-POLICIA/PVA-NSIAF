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

  def self.deregister(asset, description, reason, user_id)
    auxiliary = asset.auxiliary
    account = auxiliary.account
    userc = asset.user
    department = userc.department
    decline = new(asset_code: asset.code, account_code: account.code, auxiliary_code: auxiliary.code, department_code: department.code, user_code: userc.code, description: description, reason: reason, user_id: user_id)
    decline.save!
  end
end
