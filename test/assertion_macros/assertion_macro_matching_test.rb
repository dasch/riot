require 'teststrap'

context "matching assertion:" do
  asserts "result matches expression" do
    Riot::Assertion.new("foo") { "a" }.matches(%r[.]).run(nil)
  end.equals([:pass])

  should "fail if results do not match" do
    Riot::Assertion.new("foo") { "" }.matches(%r[.]).run(nil)
  end.equals([:fail, "expected #{%r[.].inspect} to match #{"".inspect}"])

  should "match even if expected is a string" do
    Riot::Assertion.new("foo") { "a" }.matches("a").run(nil)
  end.equals([:pass])
end # maching assertion
