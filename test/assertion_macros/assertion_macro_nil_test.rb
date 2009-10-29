require 'teststrap'

context "nil assertion:" do
  asserts("result is nil") do
    Riot::Assertion.new("foo") { nil }.nil.run(nil)
  end.equals([:pass])

  should "raise a Failure if not nil" do
    Riot::Assertion.new("foo") { "a" }.nil.run(nil)
  end.equals([:fail, "expected nil, not #{"a".inspect}"])
end # nil assertion
