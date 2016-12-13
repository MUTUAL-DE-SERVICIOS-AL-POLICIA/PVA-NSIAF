# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "bower_components")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( login.css pdf.css pdf.js )

# Extraido del tutorial para instalar fontawesome con bower para Rails
# https://github.com/platanus/guides/blob/master/setup/fontawesome-bower-rails.md
Rails.application.config.assets.precompile << Proc.new { |path| path =~ /fontawesome\/fonts/ and File.extname(path).in?(['.otf', '.eot', '.svg', '.ttf', '.woff']) }
