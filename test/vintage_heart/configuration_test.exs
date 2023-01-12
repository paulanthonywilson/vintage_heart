defmodule VintageHeart.ConfigurationTest do
  use ExUnit.Case
  alias VintageHeart.Configuration

  test "defaults" do
    assert Configuration.heart_callback?()
    assert 10_000 = Configuration.poll_interval_millis()
    assert 24 == Configuration.offline_kick_count()
    assert 84 == Configuration.offline_status_down_count()
    assert {192, 168, 0, 1} == Configuration.wizard_hotspot_ip()
  end

  test "configured" do
    refute Configuration.heart_callback?(TestPulseConfig)
    assert 20_000 = Configuration.poll_interval_millis(TestPulseConfig)
    assert 14 == Configuration.offline_kick_count(TestPulseConfig)
    assert 40 == Configuration.offline_status_down_count(TestPulseConfig)
    assert {10, 200, 12, 19} == Configuration.wizard_hotspot_ip(TestPulseConfig)
  end

  test "partial configured" do
    assert Configuration.heart_callback?(OtherTestPulseConfig)
    assert 10_000 = Configuration.poll_interval_millis(OtherTestPulseConfig)
    assert 12 == Configuration.offline_kick_count(OtherTestPulseConfig)
    assert {} == Configuration.wizard_hotspot_ip(OtherTestPulseConfig)
  end
end
