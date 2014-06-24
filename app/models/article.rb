class Article < ActiveRecord::Base
  include ManageStatus

  belongs_to :material
end
