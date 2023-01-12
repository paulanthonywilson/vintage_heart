defmodule VintageHeart.Pulse do
  @moduledoc """
  VintageHeart.

  * Without an internet connection for about 14 minutes with a 30 second check interval) reboots
  * After about 4 mins with only a 'lan' connection (no internet) kicks VintageNet by killing
  `VintageNet.RouteManager`

  All check counts are reset to zero on every heartbeat if the local ip address is 192.168.0.1, ie
  we are running the hotspot for setting up the internet connection.
  """
  use GenServer
  use VintageHeart.Vintagenet

  alias VintageHeart.Configuration

  @name __MODULE__
  require Logger

  defstruct offline_this_period_count: 0,
            offline_count: 0,
            status: :ok,
            highest_offline: 0,
            last_kick: nil

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def status do
    GenServer.call(@name, :status)
  end

  def last_kick do
    GenServer.call(@name, :last_kick)
  end

  def init(_) do
    if Process.whereis(:heart) do
      :heart.set_callback(__MODULE__, :status)
    else
      Logger.info("No heartbeat set")
    end

    schedule_poll()

    {:ok, %__MODULE__{}}
  end

  def handle_call(:status, _, %{status: status} = s) do
    {:reply, status, s}
  end

  def handle_call(:status, _, %{last_kick: last_kick} = s) do
    {:reply, last_kick, s}
  end

  def handle_info(:check, s) do
    schedule_poll()
    {:noreply, check(s)}
  end

  defp check(state) do
    if hotspot?() do
      reset_counters(state)
    else
      state
      |> check_connection()
      |> maybe_kick_vintage_net()
      |> maybe_set_status_to_down()
    end
  end

  defp check_connection(
         %{
           offline_this_period_count: lan_count,
           offline_count: net_count,
           highest_offline: highest_offline
         } = s
       ) do
    if :internet == connection_status() do
      reset_counters(s)
    else
      offline_count = net_count + 1

      %{
        s
        | offline_this_period_count: lan_count + 1,
          offline_count: offline_count,
          highest_offline: Enum.max([offline_count, highest_offline])
      }
    end
  end

  defp reset_counters(state) do
    %{state | offline_this_period_count: 0, offline_count: 0}
  end

  defp connection_status do
    Vintagenet.get_properties(["interface", "wlan0", "connection"])
  end

  defp maybe_kick_vintage_net(%{offline_this_period_count: offline_this_period_count} = s) do
    if offline_this_period_count == Configuration.offline_kick_count() do
      Vintagenet.kick()
      %{s | offline_this_period_count: 0, last_kick: DateTime.utc_now()}
    else
      s
    end
  end

  defp maybe_set_status_to_down(%{offline_count: offline_count} = s) do
    if offline_count == Configuration.offline_status_down_count() do
      %{s | status: :down}
    else
      s
    end
  end

  defp hotspot?, do: Configuration.wizard_hotspot_ip() == ipv4()

  defp ipv4 do
    ["interface", "wlan0", "addresses"]
    |> Vintagenet.get_properties()
    |> find_ipv4()
  end

  defp schedule_poll do
    Process.send_after(self(), :check, Configuration.poll_interval_millis())
  end

  defp find_ipv4(nil), do: nil

  defp find_ipv4(addresses) do
    addresses
    |> Enum.find(%{}, fn %{family: family} -> family == :inet end)
    |> Map.get(:address)
  end
end
