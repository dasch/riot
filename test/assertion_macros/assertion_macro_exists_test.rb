require 'teststrap'

context "exists assertion macro:" do
  should("pass if result has a value") do
    Riot::Assertion.new("foo") { "foo" }.exists.run(nil)
  end.equals([:pass])

  asserts("empty string is considered a passing value") do
    Riot::Assertion.new("foo") { "" }.exists.run(nil)
  end.equals([:pass])

  should "fail if value is nil" do
    Riot::Assertion.new("foo") { nil }.exists.run(nil)
  end.equals([:fail, "expected a non-nil value"])
end # exists assertion macro
