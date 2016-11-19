class AuxiliarySerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :name, :account, :status, :assets
end
