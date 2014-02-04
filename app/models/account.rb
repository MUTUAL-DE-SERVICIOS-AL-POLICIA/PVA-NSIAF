class Account < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
