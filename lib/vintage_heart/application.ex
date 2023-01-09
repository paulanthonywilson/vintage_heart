defmodule VintageHeart.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [VintageHeart.Pulse]

    opts = [strategy: :one_for_one, name: VintageHeart.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
