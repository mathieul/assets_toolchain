defmodule AssetsToolchain.Operations do
  def read_template(name), do: EEx.eval_file(full_path("#{name}.eex"))

  def read_file(name), do: File.read!(full_path(name))

  defp full_path(name) do
    path = Path.join([__DIR__, "..", "..", "templates", name])
    Path.expand(path)
  end
end
