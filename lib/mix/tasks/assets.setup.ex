defmodule Mix.Tasks.Assets.Setup do
  use Mix.Task
  import AssetsToolchain.Operations

  @shortdoc "Setup assets"

  @moduledoc """
  A task to setup Sass, Compass, Bootstrap, CoffeeScript and Guard.
  """
  def run(_args) do
    setup_bundler 1
    setup_compass 2
    setup_guard   3
    setup_jammit  4
    setup_foreman 5
    setup_web     6
    update_readme 7

    Mix.shell.info """

    The installation of the assets toolchain is done.

    For more information read the updated README.md file in your project folder.

    Quick Start:

      * edit the **dynamo.ex** file in your project lib directory and update the static route to:
        [...]
        static_route: "/"
        [...]
      * open a terminal and run (where /path/to/project is the actual path):
        $ cd /path/to/project
        $ bundle exec guard
      * open another terminal and run:
        $ cd /path/to/project
        $ mix server
      * open a browser and go to location **http://localhost:4000**

    """
  end

  defp setup_bundler(step) do
    Mix.shell.info "[#{step}] install Sass, Compass, Bootstrap, Guard..."
    File.write! "Gemfile", read_template("Gemfile")
    # Mix.shell.cmd "gem install bundler && bundle update"
    File.write! ".gitignore", read_file("gitignore"), [ :append ]
  end

  defp setup_compass(step) do
    Mix.shell.info "[#{step}] Setup compass..."
    File.mkdir_p! "./config"
    File.write! "config/compass.rb", """
    # compass.rb
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
    """
    Mix.shell.cmd "compass create . -r bootstrap-sass --using bootstrap"
    File.rm "config.rb"
    Mix.shell.cmd "mv priv/assets/stylesheets/styles.sass priv/assets/stylesheets/application.sass"
    File.write! "priv/assets/stylesheets/application.sass", """, [ :append ]

    // this partial is intended for you to override some bootstrap styles for your application
    @import customize_bootstrap
    """
    File.write! "priv/assets/stylesheets/_customize_bootstrap.sass", """
    body
      padding-top: 40px
    """
    File.mkdir_p! "priv/assets/images"
    File.mkdir_p! "priv/assets/coffeescripts"
    File.write! "priv/assets/coffeescripts/common.coffee", """
    @App =
      version: "0.0.1"
    """
    File.mkdir_p! "priv/vendor"
    Mix.shell.cmd """
    mv priv/static/images priv/vendor
    mv priv/static/javascripts priv/vendor
    touch priv/assets/favicon.ico
    """
  end

  defp setup_guard(step) do
    Mix.shell.info "[#{step}] Setup guard..."
    File.write! "Guardfile", %B"""
    # Guardfile
    require "fileutils"

    compiled_js_dir = "priv/compiled/javascripts"

    guard :coffeescript, input: "priv/assets/coffeescripts",
                         output: compiled_js_dir,
                         all_on_start: true

    guard :compass, configuration_file: "config/compass.rb", compile_on_start: true

    guard :jammit, output_folder: "priv/static/javascripts" do
      watch(%r{^#{compiled_js_dir}/(.*)\.js$})
      watch(%r{config/assets.yml})
    end

    guard :copy, from: "priv/assets/images",
                 to: "priv/static/images",
                 mkpath: true,
                 run_at_start: true

    guard :copy, from: "priv/vendor/images",
                 to: "priv/static/images",
                 mkpath: true,
                 run_at_start: true

    FileUtils.mkdir "priv/static" unless File.exists?("priv/static")
    FileUtils.cp "priv/assets/favicon.ico", "priv/static"
    """
  end

  defp setup_jammit(step) do
    Mix.shell.info "[#{step}] Setup jammit..."
    File.write! "config/assets.yml", """
    package_assets:         on
    javascript_compressor:  uglifier
    compress_assets:        off
    gzip_assets:            off

    javascripts:
      application:
        # bootstrap sources
        - priv/vendor/javascripts/bootstrap/bootstrap-transition.js
        - priv/vendor/javascripts/bootstrap/bootstrap-alert.js

        # application sources
        - priv/compiled/javascripts/common.js
    """
  end

  defp setup_foreman(step) do
    Mix.shell.info "[#{step}] Setup foreman..."
    File.write! "Procfile", """
    web: env MIX_ENV=dev elixir --sname dev -S mix server -p $PORT
    """
  end

  defp setup_web(step) do
    Mix.shell.info "[#{step}] Setup web..."
    File.mkdir_p! "web/templates/layouts"
    File.write! "web/templates/layouts/application.html.eex", """
    <!DOCTYPE HTML>
    <html lang="en">
    <head>
      <meta charset="utf-8">
      <title><%= content_for(:title) || "TODO: replace me" %></title>
      <link href="/stylesheets/application.css" rel="stylesheet">
    </head>
    <body>
      <div class="navbar navbar-fixed-top">
        <div class="navbar-inner">
          <div class="container">
            <a class="brand" href="/"><%= @title %></a>
            <ul class="nav">
              <li class="active"><a href="/">Home</a></li>
            </ul>
          </div>
        </div>
      </div>

      <div class="container">
        <div class="row">
          <div class="span12">
            <%= content_for :template %>
          </div>
        </div>
      </div>

      <script src="/javascripts/application.js"></script>
      <%= content_for :javascript %>
    </body>
    </html>
    """
    File.write! "web/templates/index.html.eex", """
    <% content_for :title do %><%= @title %> | Welcome<% end %>
    <section>
      <div class="page-header">
        <h1>Welcome to Dynamo!</h1>
      </div>
      <ol>
        <li>Change this template at <code>web/templates/index.html.eex</code></li>
        <li>Add new routes at <code>web/routers/application_router.ex</code></li>
        <li>Deploy to production with <code>MIX_ENV=prod mix do compile, server</code></li>
      </ol>
    </section>
    """
    File.write! "web/routers/application_router.ex", """
    defmodule ApplicationRouter do
      use Dynamo.Router

      prepare do
        # set a layout to use when rendering a template
        conn = conn.assign(:layout, "application")

        # Pick which parts of the request you want to fetch
        # You can comment the line below if you don't need
        # any of them or move them to a forwarded router
        conn.fetch([:cookies, :params])
      end

      # It is common to break your Dynamo in many
      # routers forwarding the requests between them
      # forward "/posts", to: PostsRouter

      get "/" do
        conn = conn.assign(:title, "Welcome to Dynamo!")
        render(conn, "index.html")
      end
    end
    """
  end

  defp update_readme(step) do
    Mix.shell.info "[#{step}] Update readme..."
    File.write! "README.md", """, [ :append ]

    ## Assets Toolchain

    In order to user the assets toolchain, you need to run the **guard** command
    in a terminal. This command will stay open (you exit with Ctrl-C) and
    regenerate your static assets when you change your source assets.

        $ cd /path/to/project
        $ bundle exec guard

        22:46:45 - INFO - Guard is using TerminalTitle to send notifications.
        22:46:45 - INFO - Compile priv/assets/coffeescripts/common.coffee
        22:46:45 - INFO - 10:46:45 PM Successfully generated priv/compiled/javascripts/common.js
        [...]

    Here is a description of all the files and folders created by assets.setup:

        ./project
        ├── ./Gemfile                 # bundler configuration (tool dependencies)
        ├── ./Gemfile.lock            # bundler lock (lock dependency versions)
        ├── ./Guardfile               # guard CLI configuration
        ├── ./Procfile                # forman configuration
        ├── ./config
        │   ├── ./config/assets.yml   # jammit configuration: define JavaScripts bundles
        │   └── ./config/compass.rb   # compass configuration
        ├── ./priv
        │   ├── ./priv/assets
        │   │   ├── ./priv/assets/coffeescripts
        │   │   │   └── # where all your CoffeeScript source files go
        │   │   ├── ./priv/assets/favicon.ico
        │   │   ├── ./priv/assets/images
        │   │   │   └── # where all your application images go
        │   │   └── ./priv/assets/stylesheets
        │   │       └── # where all Sass stylesheets go (*.sass and/or *.scss)
        │   ├── ./priv/compiled
        │   │   └── # temporary directory containing JavaScripts generated from CoffeeScripts
        │   ├── ./priv/static
        │   │   ├── # all static content served by your web application is generated
        │   │   └── # or copied here automatically for you through the guard command
        │   └── ./priv/vendor
        │       ├── ./priv/vendor/images
        │       │   └── # where all the 3rd party images go (e.g.: bootstrap icons)
        │       └── ./priv/vendor/javascripts
        │           └── # where all the 3rd party JavaScripts go (e.g.: bootstrap js files)
        └── ./web
            ├── ./web/routers
            │   └── ./web/routers/application_router.ex
            └── ./web/templates
                └── ./web/templates/index.html.eex
    """
  end
end
