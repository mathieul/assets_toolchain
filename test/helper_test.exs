defmodule AssetsToolchain.HelperTest do
  use ExUnit.Case

  alias AssetsToolchain.Helper

  test "#parse_config without css foundation" do
    config = Helper.parse_config []
    assert config.folders == [ Path.expand("../templates/common", __DIR__) ]
    assert config.compass == ""
  end
end
