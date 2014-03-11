class User < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODRESP' => 'code',
    'NOMRESP' => 'name',
    'CARGO' => 'title',
    'API_ESTADO' => 'status'
  }

  ROLES = %w[super_admin admin]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :department
  has_many :assets

  with_options if: :is_not_migrate? do |m|
    m.validates :email, presence: false, allow_blank: true
    m.validates :code, presence: true, uniqueness: { scope: :department_id }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :name, :title, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
    m.validates :ci, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true
    m.validates :username, presence: true, length: {minimum: 4, maximum: 128}, uniqueness: true, format: { with: /\A[a-z]+\z/ }
    m.validates :phone, :mobile, numericality: { only_integer: true }, allow_blank: true
    m.validates :department_id, presence: true
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: { scope: :department_id }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :department_id, presence: true
  end

  with_options if: :is_admin_or_super? do |m|
    m.validates :name, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
    m.validates :username, presence: true, length: {minimum: 4, maximum: 128}, uniqueness: true, format: { with: /\A[a-z]+\z/ }
    m.validates :role, presence: true, format: { with: /#{ROLES.join('|')}/ }
  end

  before_validation :set_defaults

  has_paper_trail ignore: [:last_sign_in_at, :current_sign_in_at, :last_sign_in_ip, :current_sign_in_ip, :sign_in_count, :updated_at, :status, :password_change, :encrypted_password]

  def active_for_authentication?
    super && self.status == '1'
  end

  def change_password(user_params)
    transaction do
      update_with_password(user_params) &&
        hide_announcement &&
        register_log(:password_changed)
    end
  end

  def inactive_message
    I18n.t('unauthorized.manage.user_inactive')
  end

  def department_code
    department.present? ? department.code : ''
  end

  def department_name
    department.present? ? department.name : ''
  end

  def depto_code
    "#{department_code}#{code}"
  end

  def depto_name
    "#{department_name} - #{name}"
  end

  def email_required?
    false
  end

  def hide_announcement
    update_column(:password_change, true)
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_admin_or_super?
    is_super_admin? || is_admin?
  end

  def is_super_admin?
    self.role == 'super_admin'
  end

  def not_assigned_assets
    # TODO Tiene que definirse que activos no están asignados,
    # tambien se debe tomar en cuenta las auto-asignaciones del admin
    assets
  end

  def password_changed?
    password_change == true
  end

  def users
    if is_super_admin?
      User.where.not(role: nil)
    elsif is_admin?
      User.where(role: nil)
    else
      User.none
    end
  end

  def self.search_by(department_id)
    users = []
    users = where(department_id: department_id) if department_id.present?
    [['', '--']] + users.map { |u| [u.id, u.name] }
  end

  def self.set_columns(cu = nil)
    h = ApplicationController.helpers
    if cu
      [h.get_column(self, 'name'), h.get_column(self, 'username'), h.get_column(self, 'role')]
    else
      [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'title'), h.get_column(self, 'ci'), h.get_column(self, 'email'), h.get_column(self, 'username'), h.get_column(self, 'phone'), h.get_column(self, 'mobile'), h.get_column(self, 'department')]
    end
  end

  def verify_assignment
    assets.present?
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user)
    array = current_user.users.includes(:department).order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      type_search = search_column == 'department' ? 'departments.name' : "users.#{search_column}"
      array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
    end
    array
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    user = { is_migrate: true, password: 'Demo1234' }
    CORRELATIONS.each do |origin, destination|
      user.merge!({ destination => record[origin] })
    end
    d = Department.find_by_code(record['CODOFIC'])
    d.present? && user.present? && new(user.merge!({ department: d })).save
  end

  def set_defaults
    if new_record? && password.nil? && !username.nil?
      self.password ||= self.username
    end
  end
end
