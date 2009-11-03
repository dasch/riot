module Riot
  class Context
    class << self
      attr_accessor :description

      def context(description, &definition)
        ctx = Class.new(self, &definition)
        ctx.description = description
        (contexts << ctx).last
      end

      def setup(description=nil, &definition)
        description = "#{rand(Time.now.to_i)}" # yuck!
        setups << define_method("setup: #{description}") { @topic = instance_eval(&definition) }
      end

      def asserts(description, &definition)
        assertion = Riot::Assertion.new(description, &definition)
        assertions << define_method("asserts: #{description}") do
          reporter.report(assertion.description, assertion.run(topic))
        end
        assertion
      end
      
      alias_method :should, :asserts

      def topic
        asserts("topic") { topic } # we will get collisions!
      end

      def run(reporter)
        contexts.each do |ctx|
          reporter.report_on_context(ctx.full_description)
          ctx.new.run(reporter)
        end
      end

      # yuck
      def full_description
        if superclass.respond_to?(:full_description)
          "#{superclass.full_description} #{description}".strip
        else
          description
        end
      end

      def assertions; @assertions ||= []; end
      def setups; @setups ||= []; end
    private
      def contexts; @contexts ||= []; end
    end

    #
    # Runtime

    attr_reader :topic, :reporter

    def initialize
      bootstrap(self.class)
    end

    def bootstrap(klass)
      bootstrap(klass.superclass) if klass.superclass && klass.superclass.respond_to?(:setups)
      klass.setups.each { |setup| instance_eval(&setup) }
    end

    def run(reporter)
      @reporter = reporter
      self.class.assertions.each { |assertion| instance_eval(&assertion) }
      self.class.run(reporter)
      self
    end

  end # Context
end # Riot
