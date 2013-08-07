
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
