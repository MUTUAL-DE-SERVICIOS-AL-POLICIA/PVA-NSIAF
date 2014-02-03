class User < ActiveRecord::Base
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

  validates :code, presence: true, uniqueness: true
  validates :name, :title, presence: true, format: { with: /\A[[:alpha:]\s]+\z/u }
  validates :ci, presence: true, uniqueness: true, numericality: { only_integer: true }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-z]+\z/ }
  validates :phone, :mobile, numericality: { only_integer: true }

  before_create :user_inactive

  ##
  # Importar el archivo DBF a la tabla de usuarios
  def self.import_dbf(dbf)
    # TODO falta asignar a un departamento
    users = DBF::Table.new(dbf.tempfile)
    i = 0; j = 0
    transaction do
      users.each_with_index do |record, index|
        print "#{index}.-\t"
        if record.present?
          CORRELATIONS.each { |k, v| print "#{record[k].inspect}, " }
          token = get_unique_tokensss
          save_correlations(record, token)
          i += 1
        else
          j += 1
          print record.inspect
        end
        puts ''
      end
    end
    [i, j]
  end

  def type_status
    state = self.status == '0' ? 'inactive' : 'active'
    I18n.t("general.#{state}")
  end

  def change_status
    state = self.status == '0' ? '1' : '0'
    self.update_attribute(:status, state)
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record, token)
    user = Hash.new
    CORRELATIONS.each do |origin, destination|
      user.merge!({ destination => record[origin] })
    end
    user.merge!({ 'username' => token })
    user.merge!({ 'email' => "#{token}@test.com" })
    user.merge!({ 'password' => token })
    create!(user)
  end

  def self.get_unique_tokensss
    loop do
      token = SecureRandom.urlsafe_base64(7)
      break token unless User.exists?(username: token)
    end
  end

  def user_inactive
    self.status = '0'
  end
end
