module ManageStatus
  extend ActiveSupport::Concern

  STATUS = {
    '0' => 'inactive',
    '1' => 'active'
  }

  included do
    unless self.const_defined?(:STATUS)
      self.const_set :STATUS, ManageStatus::STATUS
    end
    before_create :set_params
  end

  def change_status
    state = self.status == '0' ? '1' : '0'
    if self.update_attribute(:status, state)
      register_log(get_status(state))
    end
  end

  def get_status(state)
    status = self.class.const_get(:STATUS)
    status[state]
  end

  def set_params
    self.status = '1'
  end
end
