#!/usr/bin/env ruby
require 'rubygems'
require 'colored'

module RiotExperiment
  class << self
    attr_accessor :reporter
  end

  class SilentReporter
    def report(*args)
    end
  end
  
  class Reporter
    
    def report(context_description, assertion_description, assertion_results)
      print "#{context_description} - #{assertion_description}: "
      case assertion_results[0]
      when :pass
        report_pass
      when :fail
        report_fail(assertion_results[1])
      when :error
        report_error(assertion_results[1])
      end
    end
    
    def report_pass
      puts "Pass".green
    end
    
    def report_fail(msg)
      puts "Fail: #{msg}".yellow
    end
    
    def report_error(msg)
      puts "Error: #{msg}".red
    end
    
  end
  
  self.reporter = Reporter.new
  
  class Assertion
    attr_reader :topic, :description
    
    def initialize(description, &definition)
      @description = description
      @definition = definition
      self.default(nil)
    end
    
    def self.add_asserter(name, return_exceptions = false, &block)
      define_method(name) do |expected|
        (class << self; self; end).send(:define_method, :run) do |given_topic|
          @topic = given_topic
          begin
            assertion_return = instance_eval(&@definition)
            block.call(expected, assertion_return)
          rescue => e
            if return_exceptions
              block.call(expected, e)
            else
              self.class.error "Exception: #{e.inspect}"
            end
          end # exception handling
        end # define_method for :run
      end # define_method for asserter
    end
      
    add_asserter :equals do |expected, assertion_val|
      if expected === assertion_val
        pass
      else
        fail "Expected '#{expected.inspect}' but got '#{assertion_val.inspect}'"
      end
    end
    
    add_asserter :raises, true do |expected, assertion_val|
      if assertion_val.kind_of?(expected)
        pass
      else
        fail "Expected '#{expected.inspect}' but got '#{assertion_val.inspect}'"
      end        
    end
    
    add_asserter :default do |expected, assertion_val|
      if assertion_val
        pass
      else
        fail "Expected a non-false value but got: '#{val.inspect}'"
      end
    end

  private
    
    def self.pass
      return [:pass]
    end
    
    def self.fail(msg)
      return [:fail, msg]
    end
    
    def self.error(msg)
      return [:error, msg]
    end
    
  end
  
  class Context
    module SubContexts
    end
    
    attr_reader :topic
    
    def self.inherited(sub)
      sub.const_set(:SubContexts, Module.new)
    end
    
    class << self
      attr_accessor :description
    end
    
    # NOOP
    def initialize
    end
    
    def self.full_description
      if superclass.respond_to?(:full_description)
        "#{superclass.full_description} #{description}".strip
      else
        description
      end
    end
    
    def self.context(description, &definition)
      ctx = Class.new(self, &definition)
      ctx.description = description
      ctx_name = description.split.collect { |p| p.capitalize }.join.gsub(/[^a-z]/i, "")
      self::SubContexts.const_set("Context#{ctx_name}", ctx)
    end
    
    def self.setup(&definition)
      define_method(:initialize) do
        super()
        @topic = instance_eval(&definition)
      end
    end
    
    def self.assert(description, &definition)
      assertion = RiotExperiment::Assertion.new(description, &definition)
      define_method("assertion: #{description}") do 
        RiotExperiment.reporter.report(self.class.full_description, assertion.description, assertion.run(topic))
      end
      assertion
    end
    
    def run
      self.class.instance_methods(false).grep(/^assertion: /).each do |name|
        send(name)
      end
      self.class.run
    end
    
    def self.run
      self::SubContexts.constants.each do |def_name|
        self::SubContexts.const_get(def_name).new.run
      end
    end
  end
  
  def self.run
    RiotExperiment::Context.run
  end
end

if $PROGRAM_NAME == __FILE__
  class Object
    def context(description, &definition)
      RiotExperiment::Context.context(description, &definition)
    end
  end

  context("foo") do
    setup do
      "qhat"
    end
  
    assert("truth") do
      true
    end.equals(true)
    
    assert("this fails") do
      true
    end.equals(false)
    
    assert("wuh-oh") do
      raise
    end
    
    assert("dangnabbit") do
      raise
    end.raises(RuntimeError)
    
    assert("dangnabbit this fails") do
      raise
    end.raises(ArgumentError)
    
    context("bar") do
      setup do
        topic + "bar"
      end
    
      assert("is a qhatbar") do
        topic
      end.equals("qhatbar")
      
      assert("lies") do
        false
      end.equals(false)
    end
  end

  RiotExperiment.run
end