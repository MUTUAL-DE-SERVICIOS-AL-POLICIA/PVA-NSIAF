class Building < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus

  CORRELATIONS = {
    'UNIDAD' => 'code',
    'DESCRIP' => 'name'
  }

  belongs_to :entity
  has_many :departments

  validates :code, presence: true, uniqueness: { scope: :entity_id }
  validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :entity_id, presence: true

  has_paper_trail ignore: [:status, :updated_at]

  def entity_code
    entity.present? ? entity.code : ''
  end

  def entity_name
    entity.present? ? entity.name : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'entity')]
  end

  def verify_assignment
    total_departments = departments.map{|d| d.status.to_i}.sum
    total_departments > 0 ? true : false
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:entity).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      type_search = search_column == 'entity' ? 'entities.name' : "buildings.#{search_column}"
      array = array.where("#{type_search} like :search", search: "%#{sSearch}%").references(:entity)
    end
    array
  end

  def self.to_csv
    columns = %w(code name entity status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |building|
        a = Array.new
        a << building.code
        a << building.name
        a << building.entity_name
        a << h.type_status(building.status)
        csv << a
      end
    end
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    building = Hash.new
    CORRELATIONS.each do |origin, destination|
      building.merge!({ destination => record[origin] })
    end
    e = Entity.find_by_code(record['ENTIDAD'])
    e.present? && building.present? && new(building.merge!({ entity: e })).save
  end
end
