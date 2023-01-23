# credo:disable-for-this-file Credo.Check.Readability.LargeNumbers
defmodule VintageHeart.PulseTest do
  use ExUnit.Case

  alias VintageHeart.Pulse

  @tag capture_log: true
  test "initialised with empty counts" do
    assert {:ok, %{status: :ok, offline_count: 0, offline_this_period_count: 0}} = Pulse.init(:_)
  end

  test "resets counters when the VintagetNetWizard hotspot is up" do
    set_ip4({192, 168, 0, 1})
    stub_prop(:lan)

    assert {:noreply,
            %{status: :ok, offline_count: 0, offline_this_period_count: 0, highest_offline: 4}} =
             Pulse.handle_info(:check, %Pulse{
               offline_count: 2,
               offline_this_period_count: 2,
               highest_offline: 4
             })
  end

  test "offline and lan_only incremented when no ip" do
    stub_prop(["interface", "wlan0", "addresses"], [])
    stub_prop(:disconnected)

    assert {:noreply, %{status: :ok, offline_count: 5, offline_this_period_count: 3}} =
             Pulse.handle_info(:check, %Pulse{offline_count: 4, offline_this_period_count: 2})
  end

  test "resets counters when connected" do
    stub_prop(:internet)

    assert {:noreply,
            %{status: :ok, offline_count: 0, offline_this_period_count: 0, highest_offline: 3}} =
             Pulse.handle_info(:check, %Pulse{
               offline_count: 2,
               offline_this_period_count: 2,
               highest_offline: 3
             })
  end

  test "increments counters when lan, and ip4 is not the hotspot and not on internet" do
    set_ip4({192, 168, 1, 12})
    stub_prop(:lan)

    assert {:noreply, %{status: :ok, offline_count: 5, offline_this_period_count: 3}} =
             Pulse.handle_info(:check, %Pulse{offline_count: 4, offline_this_period_count: 2})
  end

  test "resets lan count, increments offline_count, and kicks VintageNet on 24th lan_only" do
    stub_prop(:lan)

    assert {:noreply,
            %{
              status: :ok,
              offline_count: 41,
              offline_this_period_count: 0,
              last_kick: %DateTime{}
            }} =
             Pulse.handle_info(:check, %Pulse{offline_count: 40, offline_this_period_count: 23})

    assert_receive :vintage_net_kicked
  end

  test "highest_offline is the highest achieved" do
    assert {:noreply, %{highest_offline: 4, offline_count: 3}} =
             Pulse.handle_info(:check, %Pulse{offline_count: 2, highest_offline: 4})

    assert {:noreply, %{highest_offline: 5}} =
             Pulse.handle_info(:check, %Pulse{offline_count: 4, highest_offline: 4})
  end

  test "is not ok after 84 offlines" do
    assert {:noreply, %{status: :down}} =
             Pulse.handle_info(:check, %Pulse{offline_count: 83, offline_this_period_count: 2})
  end

  test "status not reset at 85 n_nets" do
    assert {:noreply, %{status: :down}} =
             Pulse.handle_info(:check, %Pulse{
               offline_count: 85,
               offline_this_period_count: 2,
               status: :down
             })
  end

  test "smoke test the GenServer calls" do
    # Make sure these simple methods are properly wired up, which
    # has not always been the case

    assert nil == Pulse.last_kick()
    assert :ok == Pulse.status()
    assert %Pulse{} = Pulse.full_status()
  end

  defp set_ip4(addr) do
    addresses = [
      %{
        address: addr,
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

    stub_prop(["interface", "wlan0", "addresses"], addresses)
  end

  defp stub_prop(property \\ ["interface", "wlan0", "connection"], value) do
    send(self(), {:vn_prop, property, value})
  end
end
