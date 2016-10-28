class ResumenSerializer < ActiveModel::Serializer
  self.root = false
  attributes :nombre, :sumatoria
end
