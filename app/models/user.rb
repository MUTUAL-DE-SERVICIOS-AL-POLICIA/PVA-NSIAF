class User < ActiveRecord::Base
  include ImportDbf

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

  include Migrated

  with_options if: :is_not_migrate? do |m|
    m.validates :email, presence: false, allow_blank: true
    m.validates :code, presence: true, uniqueness: { scope: :department_id }
    m.validates :name, :title, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
    m.validates :ci, uniqueness: true, numericality: { only_integer: true }, allow_blank: true
    m.validates :username, presence: true, uniqueness: true, format: { with: /\A[a-z]+\z/ }
    m.validates :phone, :mobile, numericality: { only_integer: true }, allow_blank: true
    m.validates :department_id, presence: true
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: { scope: :department_id }
    m.validates :department_id, presence: true
  end

  before_create :status_role

  def change_status
    state = self.status == '0' ? '1' : '0'
    self.update_attribute(:status, state)
  end

  def department_name
    department.present? ? department.name : ''
  end

  def email_required?
    false
  end

  def is_super_admin?
    self.role == 'super_admin'
  end

  def is_admin?
    self.role == 'admin'
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

  def status_role
    self.status = '1'
  end
end
