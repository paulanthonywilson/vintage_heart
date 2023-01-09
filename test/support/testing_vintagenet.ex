defmodule VintageHeart.TestingVintagenet do
  @moduledoc false
  @behaviour VintageHeart.Vintagenet
  @doc """
  If the current process has a message with
  `{:vn_prop, property, value}` then value is returned
  else nil
  """
  @impl true
  def get_properties(property) do
    receive do
      {:vn_prop, ^property, value} -> value
    after
      1 -> nil
    end
  end

  @doc """
  Sends :vintage_net_kicked to the current process
  """
  @impl true
  def kick do
    send(self(), :vintage_net_kicked)
  end
end
