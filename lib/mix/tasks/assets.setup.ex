defmodule Mix.Tasks.Assets.Setup do
  use Mix.Task
  import AssetsToolchain.Helper

  @shortdoc "Setup assets"

  @moduledoc """
  A task to setup Sass, Compass, Bootstrap, CoffeeScript and Guard.
  """
  def run(_args) do
    steps = Enum.with_index([
      { &setup_bundler/0, "install Sass, Compass, Bootstrap, Guard" },
      { &setup_compass/0, "Setup compass" },
      { &setup_guard/0,   "Setup guard" },
      { &setup_jammit/0,  "Setup jammit" },
      { &setup_foreman/0, "Setup foreman" },
      { &setup_web/0,     "Setup web" },
      { &update_readme/0, "Update readme" },
    ])
    Enum.each steps, fn { { func, info }, i } ->
      Mix.shell.info "[#{i + 1}] #{info}..."
      func.()
    end
    display_instructions
  end

  defp setup_bundler do
    File.write! "Gemfile", read_file("Gemfile")
    Mix.shell.cmd "gem install bundler && bundle update"
    File.write! ".gitignore", read_file("gitignore"), [ :append ]
  end

  defp setup_compass do
    File.mkdir_p! "./config"
    File.write! "config/compass.rb", read_file("config/compass.rb")
    Mix.shell.cmd "compass create . -r bootstrap-sass --using bootstrap"
    File.rm "config.rb"
    Mix.shell.cmd "mv priv/assets/stylesheets/styles.sass priv/assets/stylesheets/application.sass"
    File.write! "priv/assets/stylesheets/application.sass",
      read_file("sass/application-append.sass"), [ :append ]
    File.write! "priv/assets/stylesheets/_customize_bootstrap.sass", read_file("sass/_customize_bootstrap.sass")
    File.mkdir_p! "priv/assets/images"
    File.mkdir_p! "priv/assets/coffeescripts"
    File.write! "priv/assets/coffeescripts/common.coffee", read_file("coffee/common.coffee")
    File.mkdir_p! "priv/vendor"
    Mix.shell.cmd """
    mv priv/static/images priv/vendor
    mv priv/static/javascripts priv/vendor
    touch priv/assets/favicon.ico
    """
  end

  defp setup_guard do
    File.write! "Guardfile", read_file("Guardfile")
  end

  defp setup_jammit do
    File.write! "config/assets.yml", read_file("config/assets.yml")
  end

  defp setup_foreman do
    File.write! "Procfile", read_file("Procfile")
  end

  defp setup_web do
    File.mkdir_p! "web/templates/layouts"
    File.write! "web/templates/layouts/application.html.eex", read_file("src/application.html.eex")
    File.write! "web/templates/index.html.eex", read_file("src/index.html.eex")
    File.write! "web/routers/application_router.ex", read_file("src/application_router.ex")
  end

  defp update_readme do
    File.write! "README.md", read_file("README-append.md"), [ :append ]
  end

  defp display_instructions do
    { { dy, dm, dd }, _time } = :calendar.now_to_local_time(:erlang.now)
    Mix.shell.info read_template("instructions.txt", [ year: dy, month: dm, day: dd ])
  end
end
