class User < ActiveRecord::Base
  include ImportDbf

  CORRELATIONS = {
    'CODRESP' => 'code',
    'NOMRESP' => 'name',
    'CARGO' => 'title',
    #'CODOFIC' => 'department_id',
    'API_ESTADO' => 'status'
  }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :department

  validates :code, presence: true, uniqueness: true
  validates :name, :title, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :ci, presence: true, uniqueness: true, numericality: { only_integer: true }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-z]+\z/ }
  validates :phone, :mobile, numericality: { only_integer: true }
  validates :department_id, presence: true

  before_create :user_inactive

  def change_status
    state = self.status == '0' ? '1' : '0'
    self.update_attribute(:status, state)
  end

  def department_name
    department.present? ? department.name : ''
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    # TODO falta asignar a un departamento
    CORRELATIONS.each { |k, v| print "#{record[k].inspect}, " }
    user = Hash.new
    CORRELATIONS.each do |origin, destination|
      user.merge!({ destination => record[origin] })
    end
    user.merge!({ 'password' => get_unique_tokens })
    new(user).save(validate: false) if user.present?
  end

  def self.get_unique_tokens
    loop do
      token = SecureRandom.urlsafe_base64(7)
      break token unless User.exists?(username: token)
    end
  end

  def user_inactive
    self.status = '0'
  end
end
