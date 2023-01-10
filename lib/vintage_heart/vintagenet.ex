defmodule VintageHeart.Vintagenet do
  @moduledoc """
  Indirection layer for `VintageNet` used within this project so we can test etc... off
  the hardware. Usage

  ```
  use VintageHeart.Vintagenet
  ```

  The appropriate module will be aliased as `Vintagenet`
  """

  @doc """
  Indirection for `VintageNet.get/1` (no default)
  """
  @callback get_properties([String.t()]) :: any()

  @doc """
  Give VintageNet a kick to induce reacquiring a (WiFi) connection, by killing
  `VintageNet.RouteManager`
  """
  @callback kick :: :ok

  defmacro __using__(_) do
    mod = implementation(apply(Mix, :env, []), apply(Mix, :target, []))

    quote do
      alias unquote(mod), as: Vintagenet
    end
  end

  def implementation(:test, _), do: VintageHeart.TestingVintagenet
  def implementation(_, :host), do: VintageHeart.StubVintagenet
  def implementation(_, _), do: VintageHeart.RealVintagenet
end
