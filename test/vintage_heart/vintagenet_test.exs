defmodule VintageHeart.VintagenetTest do
  use ExUnit.Case
  alias VintageHeart.Vintagenet

  test "test always resolves to `VintageHeart.TestingVintagenet`" do
    assert VintageHeart.TestingVintagenet == Vintagenet.implementation(:test, :host)
    assert VintageHeart.TestingVintagenet == Vintagenet.implementation(:test, :other)
    assert VintageHeart.TestingVintagenet == Vintagenet.implementation(:test, :rpi0)
  end

  test "when env is not test, then when target is host then the implementation is `VintageHeart.StubVintagenet" do
    assert VintageHeart.StubVintagenet == Vintagenet.implementation(:dev, :host)
    assert VintageHeart.StubVintagenet == Vintagenet.implementation(:prod, :host)
  end

  test "when env is not test, and the target is not host, then the implementation is the real deal" do
    assert VintageHeart.RealVintagenet == Vintagenet.implementation(:dev, :rpi0)
    assert VintageHeart.RealVintagenet == Vintagenet.implementation(:prod, :rpi0)
    assert VintageHeart.RealVintagenet == Vintagenet.implementation(:prod, :rpi3)
  end
end
