defmodule VintageHeart.Configuration do
  @moduledoc """
  Reads optional configuration for Pulse. Except for in during testing
  this library use the configuration app `:vintage_heart` with key, `VintageHeart.Pulse`.

  The following defaults will be used if not otherwise configured:any()

  * `heart_callback?` - `true`. Controls whether the application is registed as the `:heart` callback
  * `poll_interval_millis` - `10_000` - polls every 10 seconds
  * `offline_kick_count` - `24` - After 24, or whatever this is configured to, polls without an internet connection then
  `VintageNet` is kicked causing an attempted reconnection to the `wlan0`.
  * `offline_status_down_count` - `84` - After 84 internet-disconnected polls the status is set to be `:down`. Unless
  `heart_callback?` was false then `:heart` will detect the status and reboot the device.
  """

  @default_key VintageHeart.Pulse

  @defaults %{
    heart_callback?: true,
    poll_interval_millis: 10_000,
    offline_kick_count: 24,
    offline_status_down_count: 84
  }

  def heart_callback?(key \\ @default_key), do: val(key, :heart_callback?)

  def poll_interval_millis(key \\ @default_key), do: val(key, :poll_interval_millis)
  def offline_kick_count(key \\ @default_key), do: val(key, :offline_kick_count)
  def offline_status_down_count(key \\ @default_key), do: val(key, :offline_status_down_count)

  defp val(key, subkey) do
    :vintage_heart
    |> Application.get_env(key, [])
    |> Keyword.get(subkey, @defaults[subkey])
  end
end
