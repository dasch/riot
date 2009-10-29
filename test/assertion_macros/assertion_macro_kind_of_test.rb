require 'teststrap'

context "kind_of assertion:" do
  asserts "specific result is a kind of String" do
    Riot::Assertion.new("foo") { "a" }.kind_of(String).run(nil)
  end.equals([:pass])

  should "raise a Failure if not a kind of String" do
    Riot::Assertion.new("foo") { 0 }.kind_of(String).run(nil)
  end.equals([:fail, "expected kind of String, not #{0.inspect}"])
end # kind_of assertion