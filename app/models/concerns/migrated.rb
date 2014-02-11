module Migrated
  extend ActiveSupport::Concern

  included do
    attr_accessor :is_migrate
    after_initialize :init
  end

  def init
    self.is_migrate ||= false
  end

  def is_migrate?
    self.is_migrate == true
  end

  def is_not_migrate?
    self.is_migrate == false
  end
end
