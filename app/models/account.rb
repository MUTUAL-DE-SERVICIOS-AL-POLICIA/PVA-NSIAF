class Account < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name'
  }

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end
