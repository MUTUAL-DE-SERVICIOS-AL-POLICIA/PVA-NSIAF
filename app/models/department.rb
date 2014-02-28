class Department < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODOFIC' => 'code',
    'NOMOFIC' => 'name',
    'API_ESTADO' => 'status'
  }

  belongs_to :building
  has_many :users

  validates :code, presence: true, uniqueness: { scope: :building_id }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z|\"|\.|-/u }, allow_blank: true
  validates :building_id, presence: true

  has_paper_trail ignore: [:status, :updated_at]

  def building_code
    building.present? ? building.code : ''
  end

  def building_name
    building.present? ? building.name : ''
  end

  def self.search_by(building_id)
    departments = []
    departments = where(building_id: building_id) if building_id.present?
    [['', '--']] + departments.map { |d| [d.id, d.name] }
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'building')]
  end

  def verify_assignment
    total_users = users.map{|u| u.status.to_i}.sum
    total_users > 0 ? true : false
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    department = Hash.new
    CORRELATIONS.each do |origin, destination|
      department.merge!({ destination => record[origin] })
    end
    b = Building.find_by_code(record['UNIDAD'])
    b.present? && department.present? && new(department.merge!({ building: b })).save
  end
end
