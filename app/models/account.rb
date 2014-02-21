class Account < ActiveRecord::Base
  include ImportDbf, VersionLog

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name'
  }

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name')]
  end
end
