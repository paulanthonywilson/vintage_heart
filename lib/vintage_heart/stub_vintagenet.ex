# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers
defmodule VintageHeart.StubVintagenet do
  @moduledoc """
  Pretends to be VintageNet while running on the host machine. Pretends to have a connection
  and kicking does nothing.
  """

  @behaviour VintageHeart.Vintagenet
  @doc """
  """
  @impl true
  def get_properties(properties) do
    case properties do
      ["interface", "wlan0", "addresses"] ->
        [
          %{
            address: {192, 168, 1, 16},
            family: :inet,
            netmask: {255, 255, 255, 0},
            prefix_length: 24,
            scope: :universe
          },
          %{
            address: {65152, 0, 0, 0, 47655, 60415, 65071, 30543},
            family: :inet6,
            netmask: {65535, 65535, 65535, 65535, 0, 0, 0, 0},
            prefix_length: 64,
            scope: :link
          }
        ]

      ["interface", "wlan0", "internet"] ->
        :internet

      _ ->
        nil
    end
  end

  @impl true
  @doc """
  Does nothing
  """
  def kick, do: :ok
end
