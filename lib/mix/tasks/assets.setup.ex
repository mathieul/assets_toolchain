defmodule Mix.Tasks.Assets.Setup do
  use Mix.Task
  import AssetsToolchain.Helper

  @shortdoc "Setup assets"

  @moduledoc """
  A task to setup Sass, Compass, Bootstrap, CoffeeScript and Guard.
  """
  def run(args) do
    config = parse_config(args)
    steps = Enum.with_index([
      { &setup_bundler/1, "install Sass, Compass, Guard" },
      { &setup_compass/1, "Setup compass" },
      { &setup_guard/1,   "Setup guard" },
      { &setup_jammit/1,  "Setup jammit" },
      { &setup_foreman/1, "Setup foreman" },
      { &setup_web/1,     "Setup web" },
      { &update_readme/1, "Update readme" },
    ])
    Enum.each steps, fn { { func, info }, i } ->
      Mix.shell.info "[#{i + 1}] #{info}..."
      func.(config)
    end
    display_instructions(config)
  end

  defp setup_bundler(config) do
    copy_file "Gemfile", config: config
    Mix.shell.cmd "gem install bundler && bundle update"
    append_file "gitignore", to: ".gitignore", config: config
  end

  defp setup_compass(config) do
    File.mkdir_p! "./config"
    copy_file "config/compass.rb", config: config
    Mix.shell.cmd "compass create . -r bootstrap-sass --using bootstrap"
    File.rm "config.rb"
    Mix.shell.cmd "mv priv/assets/stylesheets/styles.sass priv/assets/stylesheets/application.sass"
    append_file "sass/application-append.sass", to: "priv/assets/stylesheets/application.sass", config: config
    copy_file "sass/_customize_bootstrap.sass", to: "priv/assets/stylesheets/_customize_bootstrap.sass", config: config
    File.mkdir_p! "priv/assets/images"
    File.mkdir_p! "priv/assets/coffeescripts"
    copy_file "coffee/common.coffee", to: "priv/assets/coffeescripts/common.coffee", config: config
    File.mkdir_p! "priv/vendor"
    Mix.shell.cmd """
    mv priv/static/images priv/vendor
    mv priv/static/javascripts priv/vendor
    touch priv/assets/favicon.ico
    """
  end

  defp setup_guard(config) do
    copy_file "Guardfile", config: config
  end

  defp setup_jammit(config) do
    File.mkdir_p! "./config"
    copy_file "config/assets.yml", config: config
  end

  defp setup_foreman(config) do
    copy_file "Procfile", config: config
  end

  defp setup_web(config) do
    File.mkdir_p! "web/templates/layouts"
    copy_file "src/application.html.eex",  to: "web/templates/layouts/application.html.eex", config: config
    copy_file "src/index.html.eex",        to: "web/templates/index.html.eex", config: config
    copy_file "src/application_router.ex", to: "web/routers/application_router.ex", config: config
  end

  defp update_readme(config) do
    append_file "README-append.md", to: "README.md", config: config
  end

  defp display_instructions(config) do
    { { dy, dm, dd }, _time } = :calendar.now_to_local_time(:erlang.now)
    Mix.shell.info read_template("instructions.txt", config, [ year: dy, month: dm, day: dd ])
  end
end
