class Article < ActiveRecord::Base
  include ManageStatus

  belongs_to :material

  def material_code
    material.present? ? material.code : ''
  end

  def material_name
    material.present? ? material.description : ''
  end
end
