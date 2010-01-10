require 'riot/message'

module Riot
  class AssertionMacro
    class << self
      attr_reader :expects_exception

      def default; @default_macro ||= new; end
      def expects_exception!; @expects_exception = true; end
      def register(name); Assertion.register_macro name, self; end
    end

    def pass(message=nil) [:pass, message.to_s]; end
    def fail(message) [:fail, message.to_s]; end
    def error(e) [:error, e]; end

    def expects_exception?; self.class.expects_exception; end

    def evaluate(actual)
      actual ? pass : fail("Expected non-false but got #{actual.inspect} instead")
    end

    # Messaging

    def new_message(*phrases) Message.new(*phrases); end
    def should_have_message(*phrases) new_message.should_have(*phrases); end
    def expected_message(*phrases) new_message.expected(*phrases); end
  end
end

require 'riot/assertion_macros/any'
require 'riot/assertion_macros/assigns'
require 'riot/assertion_macros/empty'
require 'riot/assertion_macros/equals'
require 'riot/assertion_macros/returns'
require 'riot/assertion_macros/equivalent_to'
require 'riot/assertion_macros/exists'
require 'riot/assertion_macros/includes'
require 'riot/assertion_macros/kind_of'
require 'riot/assertion_macros/matches'
require 'riot/assertion_macros/nil'
require 'riot/assertion_macros/not_borat'
require 'riot/assertion_macros/raises'
require 'riot/assertion_macros/respond_to'
require 'riot/assertion_macros/same_elements'
require 'riot/assertion_macros/size'
