class Entity < ActiveRecord::Base
  validates :code, :name, presence: true
end
