class Version < PaperTrail::Version
  default_scope -> { order(id: :desc) }

  def item_code
    item.present? ? item.code : ''
  end

  def item_name
    item.present? ? item.name : ''
  end

  def whodunnit_code
    user = whodunnit_obj
    user.present? ? user.code : ''
  end

  def whodunnit_name
    user = whodunnit_obj
    user.present? ? user.name : ''
  end

  def whodunnit_obj
    User.find_by_id(whodunnit)
  end
end
