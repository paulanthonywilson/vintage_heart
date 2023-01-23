# Vintage Heart

For [Nerves Project](https://nerves-project.org) apps only, specifically those using [VintageNet](https://hexdocs.pm/vintage_net/VintageNet.html) over WiFi. Really only used with Raspberry Pi Zero W's connecting over WiFi on "wlan0".

Crudely solves a problem that I have intermittenly encountered with connectivity being lost, while the IP address remains assigned. Being intermittent it is a devil to debug so this is what I use instead.


It does this by doing the following:

* Registering a the [`:heart` status callback](https://github.com/nerves-project/nerves_heart).
* Checking the `["interface", "wlan0", "connection"]` [VintageNet property](https://hexdocs.pm/vintage_net/readme.html#properties) every 10 seconds (by default). If `:internet` is returned then we assume everything is good (and counters are reset). Otherwise counters are incremented.
* On being offline for about 4 minutes (by default), VintageNet is given a bit of a kick. A kick being killing the `VintageNet.RouteManager` GenServer. This is a bit brutal, but usually does the job of going out and reconnecting with the network. 
* If we're offline for 14 minutes (by default, which will by default involve 3 kicks) we'll report to `:heart` that we are no longer ok, and it will reboot the device.

Note that 

* If the "wlan0" IP address is _192.168.0.1_ (or as otherwise configured) then it's assumed that the [VintageNetWizard](https://hexdocs.pm/vintage_net_wizard/readme.html) is being used to set up the WiFi connection, and checks will not happen
* If you compile with the default `MIX_TARGET` being host, then checking is also essentially disabled. That is it will not get in the way of you running `iex -S mix` to try out your "nerves" code on your development machine. 
* Connectivity is determined by having an "Internet connection", rather than a network connection. You can configure what having an "Internet connection" means via [VintageNet](https://hexdocs.pm/vintage_net/readme.html#internet-connectivity-checks)

This is a straight extraction, more or less, from an existing project.

## Has anything happened?

You might be interested to know if anything has happened. You can check with

```elixir

iex(1)> VintageNet.Pulse.full_status()
%VintageHeart.Pulse{
  offline_this_period_count: 0,
  offline_count: 0,
  status: :ok,
  highest_offline: 25,
  last_kick: ~U[2023-01-19 15:35:55.603980Z]
}
```

Reboots aren't logged though you can check uptime for that.


## Configuration

If you do not like the defaults then you can add some configuration to your project. The following example does nothing, in that it pointlessly confirms the default values, but you might want to change them.


```elixir
config :vintage_heart, VintageHeart.Pulse
  heart_callback?: true, #  Whether to use the status as `:heart` callback
  poll_interval_millis: :timer.seconds(10), # how often to poll
  offline_kick_count: 24, # how many polls without an internet connection before giving VintageNet a kick
  offline_status_down_count: 84, # how many polls without an internet connection before setting the status to down
  wizard_hotspot_ip: {192, 168, 0, 1} # IP used if VintageNetWizard is active as a hotspot
```

## Using

[Now an hexicle](https://hex.pm/packages/vintage_heart)

```elixir

defp deps do
  [
    # etc...
     {:vintage_heart, "~> 0.1"},
     # etc ... 
  ]
end
```