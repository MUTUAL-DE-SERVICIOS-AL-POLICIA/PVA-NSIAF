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

  validates :username, presence: true, uniqueness: true
  validates :code, :name, :title, :ci, :email, :password, presence: true

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
end
