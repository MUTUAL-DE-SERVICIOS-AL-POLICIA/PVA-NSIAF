module StoreHelper

  def is_closed_previous_year?(year = Date.today.year-1)
    Subarticle.is_closed_year?(year)
  end

end
