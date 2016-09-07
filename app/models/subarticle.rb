class Subarticle < ActiveRecord::Base
  include Migrated, ManageStatus, VersionLog
  include Autoincremento
  include CodeNumber

  belongs_to :article
  belongs_to :material
  has_many :subarticle_requests
  has_many :requests, through: :subarticle_requests
  has_many :entry_subarticles
  has_many :kardexes
  has_many :transacciones, :class_name => "Transaccion", :foreign_key => "subarticle_id"

  with_options if: :is_not_migrate? do |m|
    m.validates :material_id, presence: true
    m.validates :barcode, presence: true, uniqueness: true
    m.validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :description, :unit, presence: true
    m.validates :incremento, presence: true, uniqueness: { scope: :material_id, message: "debe ser único por material" }
    #m.validates :amount, :minimum, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    #
    # TODO validación de los códigos de barras desactivado.
    # m.validate do |subarticle|
    #   BarcodeStatusValidator.new(subarticle).validate
    # end
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, :unit, presence: true
  end

  # before_save :check_barcode

  has_paper_trail

  def self.active
    where(status: '1')
  end

  def self.close_subarticles(params)
    date = Date.strptime(params[:date], '%d/%m/%Y')
    subarticles = with_stock(params[:year]).where(id: params[:subarticle_ids])
    subarticle_ids = []
    subarticles.each do |subarticle|
      e_subarticles = subarticle.entry_subarticles_exist(params[:year]).replicate
      subarticle.close_stock!(params[:year])
      EntrySubarticle.skip_callback(:create, :after, :create_kardex_price)

      # Save entry subarticles
      e_subarticles.each do |es|
        es.amount = es.stock
        es.total_cost = es.amount * es.unit_cost
        es.note_entry = nil
        es.date = date
        es.save!
      end
      # Save kardex with multiple prices
      kardex = subarticle.kardexes.new
      kardex.kardex_date = date
      kardex.invoice_number = 0
      kardex.delivery_note_number = 0
      kardex.detail = 'SALDO INICIAL'
      kardex.order_number = 0
      kardex.set_multi_prices(e_subarticles)
      kardex.save!

      EntrySubarticle.set_callback(:create, :after, :create_kardex_price)
      subarticle_ids << subarticle.id
    end
    subarticle_ids
  end

  def self.estado_activo
    self.active
  end

  ##
  # Utilizado para la migración de artículos a materiales, por tanto se queda
  # en eliminar la categoría Artículos
  def article_material_id
    article.present? ? article.material : nil
  end

  ##
  # Obtiene un reporte en un rango de fechas dado. Adiciona el saldo a la fecha
  # seleccionada
  def reporte(desde, hasta)
    _transacciones = transacciones.saldo_al(desde)
    transacciones.where(fecha: ((desde+1)..hasta)).each do |t|
      _transacciones.push(t)
    end
    _transacciones
  end

  def kardexs(desde, hasta)
    _transacciones = transacciones.where(fecha: ((desde+1)..hasta))

    fechas = _transacciones.map { |t| t.fecha }.uniq

    lista = []
    fechas.each do |fecha|
      elegidos = _transacciones.where(fecha: fecha)
      saldos = transacciones.saldo_al(fecha - 1)
      elegidos.each do |transaccion|
        # transaccion.detalle += "- #{saldos.map(&:cantidad_saldo)}"
        saldos = transaccion.crear_items(saldos)
        # transaccion.detalle += "- #{saldos.map(&:cantidad_saldo)},  #{transaccion.cantidad}"
        lista << transaccion
      end
    end

    # Saldo Inicial
    saldo_inicial = transacciones.saldo_inicial(desde)

    # Saldo Final
    saldo_final = transacciones.saldo_final_resumen(hasta)

    lista = if !transacciones.first.nil? and desde < transacciones.first.fecha
              lista + [saldo_final]
            else
              [saldo_inicial] + lista + [saldo_final]
            end

    # Sumar saldo final
    Transaccion.generar_saldo_final(lista)

    lista
  end

  def self.minimum_stock(weight = 1.25)
    with_stock.select do |subarticle|
      subarticle.stock <= subarticle.minimum.to_i * weight
    end
  end

  def article_code
    article.present? ? article.code : ''
  end

  def article_name
    article.present? ? article.description : ''
  end

  def saldo_inicial(fecha = Date.today)
    transacciones.saldo_inicial(fecha)
  end

  def saldo_final(fecha = Date.today)
    transacciones.saldo_final(fecha)
  end

  def verify_assignment
    false
  end

  def stock
    # entry_subarticles_exist.sum(:stock)
    transacciones.sum(:cantidad)
  end

  def saldo(fecha = Date.today)
    lista = transacciones.where('fecha < ?', fecha)
    if lista.count.zero?
      transacciones.first.present? ? transacciones.first.cantidad : 0
    else
      lista.sum(:cantidad)
    end
  end

  # Only entries with stock > 0
  def entry_subarticles_exist(year = Date.today.year)
    s_date = Date.strptime(year.to_s, '%Y').beginning_of_day
    e_date = s_date.end_of_year.end_of_day
    # TODO la validación tiene que verificar si la gestión ha sido cerrada
    # caso contrario no se aplica ninguna verificación.
    #
    # entry_subarticles.search(stock_gt: 0,
    #                          date_gteq: s_date,
    #                          date_lteq: e_date).result(distinct: true)

    entry_subarticles.search(stock_gt: 0).result(distinct: true)
  end

  def kardexes_from_year(year = Date.today.year)
    s_date = Date.strptime(year.to_s, '%Y').beginning_of_year
    e_date = s_date.end_of_year
    # TODO arreglar para "cerrar" una gestión, puede ser un rango de fechas
    # kardexes.where(kardex_date: s_date..e_date)
    kardexes
  end

  ##
  # Código del material al cual pertenece los subartículos
  def material_code
    if material.present?
      material.code
    elsif article.present?
      article.material_code
    else
      ''
    end
  end

  ##
  # Descripción de model material asociado al subartículo
  def material_description
    material.present? ? material.description : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'code_old'), h.get_column(self, 'description'), h.get_column(self, 'unit'), h.get_column(self, 'material')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:material).order("#{sort_column} #{sort_direction}").references(:material)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      h = ApplicationController.helpers
      sSearch = h.changeBarcode(sSearch)
      if search_column.present?
        type_search = search_column == 'material' ? 'materials.description' : "subarticles.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("subarticles.code LIKE ? OR subarticles.code_old LIKE ? OR subarticles.description LIKE ? OR subarticles.unit LIKE ? OR materials.description LIKE ? OR subarticles.barcode LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code codel_old description unit material status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |subarticle|
        a = subarticle.attributes.values_at(*columns)
        a.pop(2)
        a.push(subarticle.material_description, h.type_status(subarticle.status))
        csv << a
      end
    end
  end

  def self.get_barcode(barcode)
    where(barcode: barcode)
  end

  def self.is_closed_year?(year = Date.today.year)
    with_stock(year).count == 0
  end

  def self.with_stock(year = Date.today.year)
    s_date = Date.strptime(year.to_s, '%Y').beginning_of_day
    e_date = s_date.end_of_year.end_of_day
    search(
      entry_subarticles_stock_gt: 0,
      entry_subarticles_date_gteq: s_date,
      entry_subarticles_date_lteq: e_date).result(distinct: true)
  end

  def exists_amount?
    # entry_subarticles_exist.present?
    transacciones.sum(:cantidad) > 0
  end

  def decrease_amount
    if entry_subarticles_exist.length > 0
      entry_subarticle = entry_subarticles_exist.first # FIFO - PEPS
      entry_subarticle.decrease_amount
    end
  end

  def final_kardex(year = Date.today.year)
    self.kardexes_from_year(year).final_kardex
  end

  def initial_kardex(year = Date.today.year)
    self.kardexes_from_year(year).initial_kardex
  end

  def self.search_subarticle(q)
    h = ApplicationController.helpers
    q = h.changeBarcode(q)
    where("(code LIKE ? OR code_old LIKE ? OR description LIKE ? OR barcode LIKE ? ) AND status = ?", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", 1).map { |s| s.entry_subarticles.first.present? ? { id: s.id, description: s.description, unit: s.unit, code: s.code, stock: s.stock, days: s.get_days } : nil }.compact
  end

  def get_days
    date = ""
    if entry_subarticles.last.date.present?
      date = Time.now.to_date - entry_subarticles.last.date
      date = date - 1
      date = date.to_i
    end
    date
  end

  def check_barcode
    if is_not_migrate?
      bcode = Barcode.find_by_code barcode
      if bcode.present?
        self.barcode = bcode.code
        bcode.change_to_used
      end
    end
  end

  def esta_activo?
    status == '1'
  end

  def last_kardex
    kardexes.last
  end

  def self.search_by(article_id)
    subarticles = []
    subarticles = where(article_id: article_id, status: 1) if artiCambiar saldo final en los kardex para que muestre el total y no así el parcial cle_id.present?
    [['', '--']] + subarticles.map { |d| [d.id, d.description] }
  end

  # Update stock=0 for all entry_subarticles
  def close_stock!(year = Date.today.year)
    entry_subarticles_exist(year).update_all(stock: 0, updated_at: Time.now)
  end

  def valorado_ingresos(desde, hasta)
    _transacciones = reporte(desde, hasta)
    _transacciones.inject(0) do |suma, transaccion|
      if transaccion.tipo == 'entrada'
        suma + (transaccion.cantidad * transaccion.costo_unitario)
      else
        suma
      end
    end
  end

  def valorado_salidas(desde, hasta)
    _transacciones = reporte(desde, hasta)
    _transacciones.inject(0) do |suma, transaccion|
      if transaccion.tipo == 'salida'
        suma + (-transaccion.cantidad * transaccion.precio_unitario)
      else
        suma
      end
    end
  end

  def valorado_saldo(desde, hasta)
    valorado_ingresos(desde, hasta) - valorado_salidas(desde, hasta)
  end
end
