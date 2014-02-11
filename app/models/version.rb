class Version < PaperTrail::Version
  def item_code
    item.present? ? (item.code || item.try(:username)) : ''
  end

  def item_name
    item.present? ? item.name : ''
  end

  def whodunnit_code
    user = whodunnit_obj
    user.present? ? (user.code || user.username || user.name) : ''
  end

  def whodunnit_name
    user = whodunnit_obj
    user.present? ? user.name : ''
  end

  def whodunnit_obj
    User.find_by_id(whodunnit)
  end
end
