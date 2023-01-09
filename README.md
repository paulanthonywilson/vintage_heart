# Vintage Heart

For [Nerves Project](https://nerves-project.org) apps only, specifically those using [VintageNet](https://hexdocs.pm/vintage_net/VintageNet.html) over WiFi. Really only used with Raspberry Pi Zero W's connecting over WiFi on "wlan0".

Crudely solves a problem that I have intermittenly encountered with connectivity being lost, while the IP address remains assigned. Being intermittent it is a devil to debug so this is what I use instead.


It does this by doing the following:

* Registering a the [`:heart` status callback](https://github.com/nerves-project/nerves_heart).
* Checking the `["interface", "wlan0", "connection"]` [VintageNet property](https://hexdocs.pm/vintage_net/readme.html#properties) every 10 seconds. If `:internet` is returned then we assume everything is good (and counters are reset). Otherwise counters are incremented.
* On being offline for about 4 minutes, VintageNet is given a bit of a kick. A kick being killing the `VintageNet.RouteManager` GenServer. This is a bit brutal, but usually does the job of going out and reconnecting with the network. 
* If we're offline for 14 minutes (involving 3 kicks) we'll report to `:heart` that we are no longer ok, and it will reboot the device.

Note that 

* If the "wlan0" IP address is _192.168.0.1_ then it's assumed that the [VintageNetWizard](https://hexdocs.pm/vintage_net_wizard/readme.html) is being used to set up the WiFi connection, and checks will not happen
* This is not a great citizen in that it sets itself up at the `:heart` callback. If you want to use something else then, depending, on application load order, you may not be able to do so. 
* If you compile with the default `MIX_TARGET` being host, then checking is also essentially disabled. That is it will not get in the way of you running `iex -S mix` to try out your "nerves" code on your development machine. 

This is a straight extraction, more or less, from an existing project. I intened to make it more configurable in the future.