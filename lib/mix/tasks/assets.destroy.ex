defmodule Mix.Tasks.Assets.Destroy do
  use Mix.Task

  @shortdoc "Destroy assets setup"

  @moduledoc """
  A task to uninstall everything that was installed by assets.setup.
  """
  def run(_args) do
    Mix.shell.info "Delete all traces of assets.setup."
    File.rm "Gemfile"
    File.rm "Gemfile.lock"
    File.rm "Guardfile"
    File.rm "Procfile"
    File.rm_rf "config"
    File.rm_rf ".sass-cache"
    File.rm_rf "priv"
    File.mkdir_p "priv/static"
    Mix.shell.cmd "touch priv/static/favicon.ico"
    File.write! ".gitignore", """
    /ebin
    /deps
    /tmp/dev
    /tmp/test
    erl_crash.dump
    """
    File.rm_rf "web/templates/layouts"
    File.write! "web/templates/index.html.eex", """
    <!DOCTYPE HTML>
    <html>
    <head>
      <title><%= @title %></title>
    </head>
    <body>
      <h3>Welcome to Dynamo!</h3>
      <ol>
        <li>Change this template at <code>web/templates/index.html.eex</code></li>
        <li>Add new routes at <code>web/routers/application_router.ex</code></li>
        <li>Deploy to production with <code>MIX_ENV=prod mix do compile, server</code></li>
      </ol>
    </body>
    </html>
    """
    File.write! "web/routers/application_router.ex", """
    defmodule ApplicationRouter do
      use Dynamo.Router

      prepare do
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
        render conn, "index.html"
      end
    end
    """
  end
end
