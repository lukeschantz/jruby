require 'test/unit'

class TestMethod < Test::Unit::TestCase
  def m0() end
  def m1(a) end
  def m2(a, b) end
  def mo1(a = nil, &b) end
  def mo2(a, b = nil) end
  def mo3(*a) end
  def mo4(a, *b, &c) end

  class Base
    def foo() :base end
  end
  class Derived < Base
    def foo() :derived end
  end

  def test_arity
    assert_equal(0, method(:m0).arity)
    assert_equal(1, method(:m1).arity)
    assert_equal(2, method(:m2).arity)
    assert_equal(-1, method(:mo1).arity)
    assert_equal(-2, method(:mo2).arity)
    assert_equal(-1, method(:mo3).arity)
    assert_equal(-2, method(:mo4).arity)
  end

  def test_unbind
    assert_equal(:derived, Derived.new.foo)
    um = Derived.new.method(:foo).unbind
    assert_instance_of(UnboundMethod, um)
    Derived.class_eval do
      def foo() :changed end
    end
    assert_equal(:changed, Derived.new.foo)
    assert_equal(:derived, um.bind(Derived.new).call)
    assert_raise(TypeError) do
      um.bind(Base.new)
    end
  end

  def test_receiver_name_owner
    o = Object.new
    def o.foo; end
    m = o.method(:foo)
    assert_equal(o, m.receiver)
    assert_equal("foo", m.name)
    assert_equal(class << o; self; end, m.owner)
    assert_equal("foo", m.unbind.name)
    assert_equal(class << o; self; end, m.unbind.owner)
  end
end
