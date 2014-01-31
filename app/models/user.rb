class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ##
  # Importar el archivo DBF a la tabla de usuarios
  def self.import_dbf(dbf)
    users = DBF::Table.new(dbf.tempfile)
    users.each_with_index do |record, index|
      print "#{index}.-\t"
      if record.present?
        print "#{record['USUAR'].inspect} ,"
        print "#{record['CODRESP'].inspect} ,"
        print "#{record['NOMRESP'].inspect} ,"
        print "#{record['CARGO'].inspect} ,"
        print "#{record['CODOFIC'].inspect} ,"
        print "#{record['API_ESTADO'].inspect} ,"
      else
        print "nil"
      end
      puts ''
    end
  end
end
