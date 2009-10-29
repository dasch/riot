#!/usr/bin/env ruby

module RiotExperiment
  class << self
    attr_accessor :reporter
  end

  class SilentReporter
    def report_error(exception)
    end
    def report_pass
    end
    def report_fail
    end
  end
  
  class Reporter
    
    def report_error(exception)
      puts "Error: #{exception.inspect}"
    end
    
    def report_pass
      puts "Pass"
    end
    
    def report_fail
      puts "Fail"
    end
  end
  
  self.reporter = Reporter.new
  
  class Assertion
    attr_reader :topic
    def initialize(description, &definition)
      @description = description
      @definition = definition
    end
    
    def equals(expected)
      (class << self; self; end).send(:define_method, :run) do |given_topic|
        @topic = given_topic
        begin
          if instance_eval(&@definition) === expected
            RiotExperiment.reporter.report_pass
          else
            RiotExperiment.reporter.report_fail
          end          
        rescue => e
          RiotExperiment.reporter.report_error(e)
        end
      end
    end
    
    def run(given_topic)
      @topic = given_topic
      if instance_eval(&@definition)
        RiotExperiment.reporter.report_pass
      else
        RiotExperiment.reporter.report_fail
      end
    rescue => e
      RiotExperiment.reporter.report_error(e)
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
    
    def self.context(description, &definition)
      ctx = Class.new(self, &definition)
      ctx.description = description
      ctx_name = description.split.collect { |p| p.capitalize }.join.gsub(/[^a-z]/i, "")
      self::SubContexts.const_set("Context#{ctx_name}", ctx)
    end
    
    def self.setup(&definition)
      define_method(:initialize) do
        super
        @topic = instance_eval(&definition)
      end
    end
    
    def self.assert(description, &definition)
      assertion = RiotExperiment::Assertion.new(description, &definition)
      define_method("assertion: #{description}") { assertion.run(topic) }
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

# 
# class Object
#   def context(description, &definition)
#     RiotExperiment::Context.context(description, &definition)
#   end
# end
# 
# context("foo") do
#   setup do
#     puts "hi mom"
#   end
#   
#   assert("truth") do
#     true
#   end.equals(true)
#   
#   context("bar") do
#     setup do
#       puts "hi dad"
#     end
#     
#     assert("lies") do
#       false
#     end.equals(false)
#   end
# end
# 
# RiotExperiment.run