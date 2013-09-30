## Assets Toolchain ##

Assets Toolchain is a set of Mix tasks and configuration templates to setup
Sass, CoffeeScript, Bootstrap and more for your
[Dynamo](https://github.com/elixir-lang/dynamo) projects.

After you run the **assets.setup** task in a new dynamo project, it will setup
the following tools:

* [Sass](http://sass-lang.com) and [Compass](http://compass-style.org), THE CSS stylesheet generator and its essential CSS framework companion
* [Bootstrap](http://getbootstrap.com), the Twitter frontend framework to quickly bootstrap new web applications (via [Bootstrap for Sass](https://github.com/thomas-mcdonald/bootstrap-sass))
* [Guard](http://guardgem.org), a CLI for dynamically re-compiling Sass and CoffeeScript files as you update them
* [Jammit](http://documentcloud.github.io/jammit/), to use as an asset packaging CLI for CoffeeScript files
* [Foreman](https://github.com/ddollar/foreman) to manage 
* [Bundler](http://bundler.io), a dependency library manager to manage the Ruby library dependencies of all those tools

## Installation ##

### 1- Install Ruby if not present already ###

Since most of the tools of this assets toolchain are written in Ruby, you will
need a Ruby runtime, such as MRI, JRuby or Rubinius.

If you don't already have Ruby installed on your development machine, here are
some resources:

* [rbenv](https://github.com/sstephenson/rbenv)
* [rvm](https://rvm.io)
* [MRI Ruby](https://www.ruby-lang.org/en/downloads/)
* [Tokaido](https://github.com/tokaido/tokaidoapp/releases)

### 2- Install AssetsToolchain in your Dynamo project ###

Once you have Ruby installed, create your Dynamo project as described in
[the dynamo README](https://github.com/elixir-lang/dynamo#installation)
and edit the file ```mix.exs``` to add **assets_toolchain** as a dependency:

```elixir
  defp deps do
    [ { :cowboy, github: "extend/cowboy" },
      { :dynamo, "0.1.0-dev", github: "elixir-lang/dynamo" },
      { :assets_toolchain, github: "mathieul/assets_toolchain" } ]
  end
```

If you don't want to load **assets_toolchain** in production or test mode, you can
specify instead declare ```deps``` as below:

```elixir
  defp deps, do: deps(:dev)
  defp deps(:prod) do
    [ { :cowboy, github: "extend/cowboy" },
      { :dynamo, "0.1.0-dev", github: "elixir-lang/dynamo" } ]
  end
  defp deps(_) do
    deps(:prod) ++ [ { :assets_toolchain, github: "mathieul/assets_toolchain" } ]
  end
```

and install the project dependencies with ```mix```:

```sh
$ cd /path/to/project
$ mix deps.get
```

### 3- Setup Assets ###

Finally you just need to run the ```assets.setup``` task to generate the configuration,
install the tools and generate the scaffold templates.

```sh
$ cd /path/to/project
$ mix assets.setup
```

### 4- Test it worked ###

Run ```guard``` to compile assets and monitor asset sources for changes:

```sh
$ cd /path/to/project
$ bundle exec guard
```

Open a new terminal window to start the web server:

```sh
$ cd /path/to/project
$ mix server
```

Now open a browser and go to location **http://localhost:4000**.
