class Documento < ActiveRecord::Base

  alias_attribute :creado_el, :created_at

end
