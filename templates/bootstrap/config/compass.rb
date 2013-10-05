require "bootstrap-sass"

http_path = "/"
css_dir = "priv/static/stylesheets"
sass_dir = "priv/assets/stylesheets"
images_dir = "priv/static/images"
javascripts_dir = "priv/static/javascripts"
add_import_path File.expand_path("../../priv/vendor/stylesheets", __FILE__)

# output_style = :expanded or :nested or :compact or :compressed
output_style = :expanded
relative_assets = true
preferred_syntax = :sass
