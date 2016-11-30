class SupplierSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :nit, :telefono, :contacto, :created_at, :note_entries,
             :ingresos

  has_many :note_entries, serializer: NotaEntradaSerializer
  has_many :ingresos, serializer: IngresoSerializer

  def created_at
    I18n.l(object.created_at, format: :long ) if object.created_at.present?
  end

  def note_entries
    serialization_options[:role] == 'admin_store' || serialization_options[:role] == 'super_admin' ?  object.note_entries : []
  end

  def ingresos
    serialization_options[:role] == 'admin' || serialization_options[:role] == 'super_admin' ? object.ingresos : []
  end
end
