module NavigationHelper
  def currently_at(tab)
    render 'layouts/main_nav', current_tab: tab
  end

  def nav_tab(title, url, options = {})
    current_tab = options.delete(:current)
    options[:class] = (current_tab == title) ? 'active' : ''
    content_tag(:li, link_to(title, url), options)
  end
end
