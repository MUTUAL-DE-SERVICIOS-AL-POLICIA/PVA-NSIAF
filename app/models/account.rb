class Account < ActiveRecord::Base
  include ImportDbf, VersionLog

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name'
  }

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name')]
  end
end
