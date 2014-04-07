class MaterialRequest < ActiveRecord::Base
  belongs_to :material
  belongs_to :request
end
