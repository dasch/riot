require 'teststrap'

context "equals assertion:" do
  asserts "result equals expectation" do
    Riot::Assertion.new("i will pass") { "foo bar" }.equals("foo bar").run(nil)
  end.equals([:pass])

  should "fail if results don't equal each other" do
    Riot::Assertion.new("failure") { "bar" }.equals("foo").run(nil)
  end.equals([:fail, "expected #{"foo".inspect}, not #{"bar".inspect}"])
end # equals assertion
