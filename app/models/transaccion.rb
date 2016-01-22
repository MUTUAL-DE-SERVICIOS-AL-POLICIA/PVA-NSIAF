class Transaccion < ActiveRecord::Base
  self.table_name = 'entradas_salidas'

  belongs_to :subarticle
end
