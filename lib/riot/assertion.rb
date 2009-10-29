module Riot
  class Assertion
    attr_reader :description, :topic
    def initialize(description, &definition)
      @description = description
      @definition = definition
      self.default(nil)
    end
    
    alias_method :to_s, :description

    class << self
      # This is how we define a new macro ...
      def assertion_macro(name, assert_exception=false, &assertion_block)
        define_method(name) do |*expectings|
          (class << self; self; end).send(:define_method, :run) do |given_topic|
            @topic = given_topic
            evaluate(assert_exception, *expectings, &assertion_block)
          end # define_method for :run
          self
        end # define_method for asserter
      end
    end # self

    assertion_macro(:default) do |actual, expected|
      actual ? pass : fail("Expected a non-false value but got #{actual.inspect} instead")
    end
  private
    def self.pass; [:pass]; end
    def self.fail(msg) [:fail, msg]; end
    def self.error(msg) [:error, msg]; end

    def evaluate(assert_exception, *expectings, &assertion_block)
      begin
        actual = instance_eval(&@definition)
        actual = nil if assert_exception
        assertion_block.call(actual, *expectings)
      rescue Exception => e
        assert_exception ? assertion_block.call(e, *expectings) : self.class.error(e)
      end
    end
  end # Assertion
end # Riot