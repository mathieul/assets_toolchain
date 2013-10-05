defmodule AssetsToolchain.Helper do

  @template_dir Path.expand("../../templates", __DIR__)

  defrecord Config, folders: []

  def parse_config(args) do
    options = OptionParser.parse(args, aliases:  [c: :css])
    paths = case options do
      { [ css: css ], _ } -> [ css, "common" ]
      _                   -> [ "common" ]
    end
    folders = Enum.map paths, &(Path.join([@template_dir, &1]))
    Config.new folders: folders
  end

  def read_template(name, config, binding // []) do
    content = full_path("#{name}.eex", config)
    if content, do: EEx.eval_file(content, binding), else: ""
  end

  def read_file(name, config) do
    content = full_path(name, config)
    if content, do: File.read!(content), else: ""
  end

  def copy_file(source, options, write_options // []) do
    content = read_file(source, Keyword.get(options, :config))
    unless content == "" do
      destination = Keyword.get options, :to, source
      File.write! destination, content, write_options
    end
  end

  def append_file(source, options) do
    copy_file(source, options, [ :append ])
  end

  defp full_path(file_name, config) do
    paths = Enum.map config.folders, &(Path.join [&1, file_name])
    path = Enum.find paths, &File.exists?/1
    if path, do: path, else: nil
  end
end
