require 'teststrap'

context "assigns assertion" do
  setup do
    Class.new { def initialize; @foo, @bar = "bar", nil; end }.new
  end

  asserts("an instance variable was assigned") do
    Riot::Assertion.new("duh") { topic }.assigns(:foo).run(topic)
  end.equals([:pass])

  asserts("an instance variable was never assigned") do
    Riot::Assertion.new("foo") { topic }.assigns(:baz).run(topic)
  end.equals([:fail, "expected @baz to be assigned a value"])
  
  asserts("an instance variable was assigned a specific value") do
    Riot::Assertion.new("duh") { topic }.assigns(:foo, "bar").run(topic)
  end.equals([:pass])

  asserts("failure when instance never assigned even when a value is expected") do
    Riot::Assertion.new("duh") { topic }.assigns(:bar, "bar").run(topic)
  end.equals([:fail, "expected @bar to be assigned a value"])

  asserts("failure when expected value is not assigned to variable with a value") do
    Riot::Assertion.new("duh") { topic }.assigns(:foo, "baz").run(topic)
  end.equals([:fail, "expected @foo to be equal to 'baz', not 'bar'"])
end # assigns assertion
