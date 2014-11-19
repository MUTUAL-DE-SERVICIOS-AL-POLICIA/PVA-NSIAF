class Request < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :subarticle_requests
  has_many :subarticles, through: :subarticle_requests
  accepts_nested_attributes_for :subarticle_requests

  def user_name
    user.present? ? user.name : ''
  end

  def user_title
    user.present? ? user.title : ''
  end

  def admin_name
    admin.present? ? admin.name : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'id'), h.get_column(self, 'created_at'), h.get_column(self, 'name'), h.get_column(self, 'title')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, status)
    status = status == '' || status == nil ? 'all' : status
    array = joins(:user).order("#{sort_column} #{sort_direction}")
    array = array.where(status: status) unless status == 'all'
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(name title).include?(search_column) ? "users.#{search_column}" : "requests.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")#.references(:user)
      else
        array = array.where("requests.id LIKE ? OR requests.created_at LIKE ? OR users.name LIKE ? OR users.title LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(id created_at name title)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |request|
        a = request.attributes.values_at(*columns)
        a.pop(3)
        a.push(I18n.l(request.created_at, format: :version))
        a.push(request.user_name)
        a.push(request.user_title)
        csv << a
      end
    end
  end

  def delivery_verification(barcode)
    subarticles = Subarticle.get_barcode(barcode)
    s_request = nil
    if subarticles.present?
      if subarticles.exists_amount?
        subarticle = subarticles.first
        s_request = subarticle_requests.get_subarticle(subarticle.id)
        if s_request.present?
          if s_request.total_delivered < s_request.amount_delivered
            subarticle.decrease_amount
            s_request.increase_total_delivered
            request_deliver unless subarticle_requests.is_delivered?
          end
        end
      else
        s_request = { amount: 0 }
      end
    end
    s_request
  end

  def request_deliver
    update_attributes(status: 'delivered', delivery_date: Time.now )
  end
end
