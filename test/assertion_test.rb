require 'teststrap'

context "basic assertion" do
  should "have a description" do
    Riot::Assertion.new("i will pass").to_s
  end.equals("i will pass")

  asserts ":pass is returned from run when assertion passed" do
    Riot::Assertion.new("i will pass") { true }.run(nil)
  end.equals([:pass])

  asserts ":fail with message is returned from run when assertion does not pass" do
    Riot::Assertion.new("i will pass") { false }.run(nil)
  end.equals([:fail, "Expected a non-false value but got false instead"])

  asserts ":error is returned from run when an unexpected Exception is raised" do
    Riot::Assertion.new("error") { raise Exception, "blah" }.run(nil).first
  end.equals(:error)

  asserts "the exception is returned from run when an unexpected Exception is raised" do
    Riot::Assertion.new("error") { raise Exception, "blah" }.run(nil).last
  end.kind_of(Exception)

  # DO WE STILL NEED THIS?
  # context "that fails while executing a test" do
  #   setup do
  #     fake_situation = Riot::Situation.new
  #     Riot::Assertion.new("error") { fail("I'm a bum") }.run(nil)
  #   end
  # 
  #   should("be considered a failing assertion") { topic.failed? }
  #   should("use failed message in description") { topic.result.message }.matches(/I'm a bum/)
  # end # that fails while executing test
end # basic assertion
