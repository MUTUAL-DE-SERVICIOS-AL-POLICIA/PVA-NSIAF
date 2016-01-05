class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    if current_user && !current_user.has_roles?
      redirect_to welcome_index_url
    else
      redirect_to root_url, :alert => exception.message
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def format_to(name_model, datatable)
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: datatable.new(view_context) }
      column_order = name_model == 'proceedings' ? 'users.name' : %w(versions requests note_entries).include?(name_model) ? 'id' : "#{name_model}.code"
      case controller_name
      when 'derecognised' then current = '0'
      when 'assets' then current = '1'
      when 'requests' then current = params[:status]
      else current = current_user
      end
      @array = name_model.classify.constantize.array_model(column_order, 'asc', '', '', params[:sSearch], params[:search_column], current)
      array_csv = controller_name == 'derecognised' ? @array.to_csv(true) : @array.to_csv
      filename = "VSIAF-#{t("#{name_model}.title.title")}".parameterize
      format.csv { send_data array_csv, filename: "#{filename}.csv" }
      format.pdf do
        render pdf: filename,
               template: "#{name_model}/index.pdf.haml",
               disposition: 'attachment',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: { top: 10, bottom: 20, left: 15, right: 15 },
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  def info_for_paper_trail
    unless %w(dbf sessions proceedings requests).include?(request[:controller]) || %w(change_status update_password change_status).include?(request[:action])
      { item_spanish: I18n.t(controller_name.to_s.downcase.singularize, scope: 'activerecord.models'), event: I18n.t(action_name, scope: 'versions') }
    end
  end
end
