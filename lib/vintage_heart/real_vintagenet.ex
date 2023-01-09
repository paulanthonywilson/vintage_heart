defmodule VintageHeart.RealVintagenet do
  @moduledoc false

  @behaviour VintageHeart.Vintagenet

  require Logger

  @impl true
  def get_properties(properties) do
    apply(VintageNet, :get, [properties])
  end

  @impl true
  def kick do
    case Process.whereis(VintageNet.RouteManager) do
      nil ->
        Logger.error("VintageNet.RouteManager could not be found to be kicked")

      pid ->
        Logger.info("Kicking VintageNet.RouteManager")
        Process.exit(pid, :exit)
    end

    :ok
  end
end
