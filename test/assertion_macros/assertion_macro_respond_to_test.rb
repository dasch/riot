require 'teststrap'

context "respond to" do
  should "pass when object responds to expected method" do
    Riot::Assertion.new("foo") { "foo" }.respond_to(:each_byte).run(nil)
  end.equals([:pass])

  should "fail when object does not respond to expected method" do
    Riot::Assertion.new("foo") { "foo" }.respond_to(:goofballs).run(nil)
  end.equals([:fail, "expected method :goofballs is not defined"])

end # respond to
