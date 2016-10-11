class UserSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :name, :username, :title, :ci, :email, :entity_name, :department_name, :phone, :mobile, :role, :estado, :urls

  def estado
    object.status == "1" ? 'ACTIVO' : 'INACTIVO'
  end

  def urls
    {
      list: users_url(host: Rails.application.secrets.rails_host),
      show: user_url(object, host: Rails.application.secrets.rails_host),
      edit: edit_user_url(object, host: Rails.application.secrets.rails_host),
      historico: obt_historico_actas_api_user_url(object , format: :json ,host: Rails.application.secrets.rails_host),
      download_activos_pdf: download_user_url(object, format: :pdf, host: Rails.application.secrets.rails_host),
      download_activos_csv: download_user_url(object, format: :csv, host: Rails.application.secrets.rails_host)
    }
  end
end
