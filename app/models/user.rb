class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username, presence: true, uniqueness: true

  CORRELATIONS = {
    'CODRESP' => 'code',
    'NOMRESP' => 'name',
    'CARGO' => 'title',
    #'CODOFIC' => 'department_id',
    'API_ESTADO' => 'status'
  }

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
end
