import Config

# Remember that config is not loaded when this is used as a libarary. (And libraries are also always compiled as `:prod`)

config :vintage_heart, TestPulseConfig,
  heart_callback?: false,
  poll_interval_millis: :timer.seconds(20),
  offline_kick_count: 14,
  offline_status_down_count: 40,
  wizard_hotspot_ip: {10, 200, 12, 19}

config :vintage_heart, OtherTestPulseConfig,
  heart_callback?: true,
  offline_kick_count: 12,
  wizard_hotspot_ip: {}
