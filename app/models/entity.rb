class Entity < ActiveRecord::Base
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :acronym, presence: true

  has_paper_trail

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'acronym')]
  end
end
