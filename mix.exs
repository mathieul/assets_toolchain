defmodule AssetsToolchain.Mixfile do
  use Mix.Project

  def project do
    [ app: :assets_toolchain,
      version: "0.0.1",
      elixir: "~> 0.10.0",
      deps: deps ]
  end

  def application do
    []
  end

  defp deps do
    []
  end
end
