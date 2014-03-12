class Proceeding < ActiveRecord::Base
  include VersionLog

  PROCEEDING_TYPE = {
    'E' => 'assignation',
    'D' => 'devolution'
  }

  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :asset_proceedings
  has_many :assets, through: :asset_proceedings

  after_create :update_assignations

  has_paper_trail on: [:destroy]

  def self.set_columns
   h = ApplicationController.helpers
   c_names = column_names - %w(id created_at updated_at proceeding_type)
   c_names.map{ |c| h.get_column(self, c) unless c == 'object' }.compact
  end

  def admin_name
    admin ? admin.name : ''
  end

  def code
    user ? user.depto_code : ''
  end

  def name
    user ? user.depto_name : ''
  end

  def get_type
    PROCEEDING_TYPE[proceeding_type]
  end

  ##
  # Tipo de Acta:
  #   E: Asignación, Entrega de Activos
  #   D: Devolución de Activos
  def is_assignation?
    proceeding_type == 'E'
  end

  def is_devolution?
    proceeding_type == 'D'
  end

  def user_name
    user ? user.name : ''
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:user, :admin).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      type_search = "proceedings.#{search_column}"
      case search_column
      when 'user_id' then type_search = 'users.name'
      when 'admin_id' then type_search = 'admins_proceedings.name'
      end
      array = array.where("#{type_search} like :search", search: "%#{sSearch}%")#.references(:user, :admin)
    end
    array
  end

  private

  def update_assignations
    user_id = self.admin_id
    event = 'devolution'
    if is_assignation?
      user_id = self.user_id
      event = 'assignation'
    end
    assets.update_all(user_id: user_id)
    register_log(event)
  end

  def self.to_csv(column_names)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        a = [product.user_name, product.admin_name, I18n.t(product.get_type, scope: 'proceedings.type'), I18n.l(product.created_at, format: :version)]
        csv << a
      end
    end
  end
end
