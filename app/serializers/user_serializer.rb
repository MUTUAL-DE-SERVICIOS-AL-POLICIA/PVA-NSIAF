class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :title, :ci, :entity_name, :department_name
end
