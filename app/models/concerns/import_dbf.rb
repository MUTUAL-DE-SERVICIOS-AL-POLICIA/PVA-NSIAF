module ImportDbf
  extend ActiveSupport::Concern

  module ClassMethods
    ##
    # Importar el archivo DBF a la tabla de usuarios
    def import_dbf(dbf)
      users = DBF::Table.new(dbf.tempfile)
      i = 0; j = 0
      transaction do
        users.each_with_index do |record, index|
          print "#{index + 1}.-\t"
          if record.present?
            save_correlations(record)
            i += 1
          else
            j += 1
            print record.inspect
          end
          puts ''
        end
      end
      [i, j] # insertados, nils
    end

    private

    ##
    # Guarda en la base de datos de acuerdo a la correspondencia de campos.
    def save_correlations(record)
      import_data = Hash.new
      CORRELATIONS.each do |origin, destination|
        import_data.merge!({ destination => record[origin] })
      end
      self.new(import_data).save(validate: false) if import_data.present?
    end
  end
end
