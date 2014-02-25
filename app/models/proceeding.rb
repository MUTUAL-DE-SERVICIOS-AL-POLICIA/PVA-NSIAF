class Proceeding < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :assets_proceedings
  has_many :assets, through: :assets_proceedings
end
