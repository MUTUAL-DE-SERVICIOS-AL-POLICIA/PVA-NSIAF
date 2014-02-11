class Account < ActiveRecord::Base
  include ImportDbf, VersionLog

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name'
  }

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  has_paper_trail
end
