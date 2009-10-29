module Riot
  class Context
    # module SubContexts
    # end
    # 
    class << self
      attr_accessor :description

      # def inherited(sub)
      #   sub.const_set(:SubContexts, Module.new)
      # end
      # 
      def context(description, &definition)
        ctx = Class.new(self, &definition)
        ctx.description = description
        (contexts << ctx).last
        # context_name = description.split.collect { |p| p.capitalize }.join.gsub(/[^a-z]/i, "")
        # self::SubContexts.const_set("Context#{context_name}", ctx)
      end

      def setup(description=nil, &definition)
        description = "#{Time.now.to_i}#{rand(Time.now.to_i)}"
        define_method("setup: #{description}") { instance_eval(&definition) }
      end

      def asserts(description, &definition)
        assertion = Riot::Assertion.new(description, &definition)
        define_method("asserts: #{description}") do
          reporter.report(assertion.description, assertion.run(topic))
        end
        assertion
      end
      
      alias_method :should, :asserts

      def topic
        asserts("topic") { topic } # we will get collisions!
      end

      def run(reporter)
        # self::SubContexts.constants.each do |def_name|
        #   ctx = self::SubContexts.const_get(def_name)
        #   reporter.report_on_context(ctx.full_description)
        #   ctx.new.run(reporter)
        # end
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
      bootstrap(klass.superclass) if klass.superclass
      klass.instance_methods(false).grep(/^setup: /).each do |name|
        @topic = send(name)
      end
    end

    def run(reporter)
      @reporter = reporter
      self.class.instance_methods(false).grep(/^asserts: /).each do |name|
        send(name)
      end
      self.class.run(reporter)
      self
    end

  end # Context
end # Riot
