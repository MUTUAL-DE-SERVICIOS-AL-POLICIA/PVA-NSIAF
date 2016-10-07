class UserSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :name, :username, :title, :ci, :email, :entity_name, :department_name, :phone, :mobile, :role, :estado

  def estado
    object.status == "1" ? 'ACTIVO' : 'INACTIVO'
  end

end
