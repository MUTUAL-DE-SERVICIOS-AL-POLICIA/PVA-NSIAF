class Entity < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :acronym, presence: true
end
