module ApplicationHelper
  def assets_json(assets, user)
    assets = assets.each_with_index.map do |a, index|
      { index: index + 1, id: a.id, description: a.description, code: a.code }
    end
    { assets: assets.as_json, user_name: user.name, user_title: user.title}
  end
  ##
  # Mime-types para los archivos *.dbf
  def dbf_mime_types
    %w(application/dbase application/x-dbase application/dbf application/x-dbf zz-application/zz-winassoc-dbf)
  end

  def get_buildings
    Building.all.map { |b| [b.name, b.id] }
  end

  def get_i18n_roles
    User::ROLES.map { |r| [t(r, scope: 'users.roles'), r] }
  end

  def proceeding_to_json(proceeding)
    assets = proceeding.assets.each_with_index.map do |a, index|
      { index: index + 1, id: a.id, description: a.description, code: a.code }
    end
    {
      admin_name: proceeding.admin_name,
      assets: assets.to_json,
      proceeding_date: I18n.l(proceeding.created_at.to_date, format: :long )
    }
  end

  def submit_and_cancel(url)
    content_tag(:button, class: 'btn btn-primary') do
      content_tag(:span, '', class: 'glyphicon glyphicon-ok') + ' ' +
      t("general.btn.save")
    end + ' ' +
    link_to(url, class: 'btn btn-danger') do
      content_tag(:span, '', class: 'glyphicon glyphicon-remove') + ' ' +
      t("general.btn.cancel")
    end
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def type_status(status)
    state = status == '0' ? 'inactive' : 'active'
    t("general.#{state}")
  end

  def title_status(type)
    state = type == '0' ? 'active' : 'deactive'
    t("general.btn.#{state}")
  end

  def img_status(status)
    status == '0' ? 'ok' : 'remove'
  end

  def get_column(model, column)
    [model.human_attribute_name(column), column]
  end

  def data_link(model)
    assignment = model.verify_assignment
    if model.status == '1'
      state = assignment ? 'cannot_disable' : 'deactivate'
    else
      state = 'activate'
    end
    klass = model.class.name
    {
      dom_id: dom_id(model),
      title: t("#{ klass.tableize }.title.modal"),
      confirm_message: t("#{ klass.tableize }.title.confirm-#{ state }", name: model.name),
      url: eval("change_status_#{ klass.underscore }_path(model)"),
      unassigned: !assignment
    }
  end

  def links_actions(user)
    unless user.role == 'super_admin'
      link_to(content_tag(:span, "", class: 'glyphicon glyphicon-eye-open') + I18n.t('general.btn.show'), user, class: 'btn btn-default btn-sm') + ' ' +
      link_to(content_tag(:span, "", class: 'glyphicon glyphicon-edit') + I18n.t('general.btn.edit'), [:edit, user], class: 'btn btn-primary btn-sm') + ' ' +
      link_to(content_tag(:span, '', class: "glyphicon glyphicon-#{img_status(user.status)}") + title_status(user.status), '#', class: 'btn btn-warning btn-sm', data: data_link(user))
    end
  end

  def status_active(model)
    model.where(status: '1')
  end

  def yield_or_default(section, default = "")
    content_for?(section) ? content_for(section) : default
  end
end
