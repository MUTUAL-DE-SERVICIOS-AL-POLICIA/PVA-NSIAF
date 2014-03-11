class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
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

  def format_to(name_model, datatable, columns)
    respond_to do |format|
      format.html { render '/shared/index' }
      format.json { render json: datatable.new(view_context) }
      @array = name_model.classify.constantize.array_model('code', 'asc', '', '', params[:sSearch], params[:search_column], current_user)
      format.csv { render text: @array.to_csv(columns) }
      format.pdf do
        render pdf: "VSIAF-#{t("#{name_model}.title.title")}",
               disposition: 'attachment',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: { top: 15, bottom: 15, left: 20, right: 15 }
      end
    end
  end
end
