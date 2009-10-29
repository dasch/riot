require 'teststrap'

class MyException < Exception; end

context "raises assertion:" do

  should "raise an Exception" do
    Riot::Assertion.new("foo") { raise Exception }.raises(Exception).run(nil)
  end.equals([:pass])

  should "fail if nothing was raised" do
    Riot::Assertion.new("foo") { "barf" }.raises(Exception).run(nil)
  end.equals([:fail, "should have raised Exception, but raised nothing"])

  should "fail if Exception classes do not match" do
    Riot::Assertion.new("foo") { raise MyException }.raises(Exception).run(nil)
  end.equals([:fail, "should have raised Exception, not MyException"])

  should "pass if provided message equals expectation" do
    Riot::Assertion.new("foo") { raise Exception, "I'm a nerd" }.raises(Exception, "I'm a nerd").run(nil)
  end.equals([:pass])

  should "fail if provided message does not equal expectation" do
    Riot::Assertion.new("foo") { raise(Exception, "I'm a nerd") }.raises(Exception, "But I'm not").run(nil)
  end.equals([:fail, "expected But I'm not for message, not I'm a nerd"])

  should "pass if provided message matches expectation" do
    Riot::Assertion.new("foo") { raise(Exception, "I'm a nerd") }.raises(Exception, /nerd/).run(nil)
  end.equals([:pass])
  
  should "fail if provided message does not match expectation" do
    Riot::Assertion.new("foo") { raise(Exception, "I'm a nerd") }.raises(Exception, /foo/).run(nil)
  end.equals([:fail, "expected #{/foo/} for message, not I'm a nerd"])
  
end # raises assertion