require 'riot/report'
require 'riot/context'
require 'riot/assertion'
require 'riot/assertion_macros'

module Riot
  # Configuration

  def self.reporter; @reporter ||= (Riot.silently? ? NilReport.new : DotMatrixReport.new); end
  def self.reporter=(report); @reporter = report; end
  def self.silently!; @silently = true; end
  def self.silently?; @silently || false; end

  def self.run(a_reporter)
    Riot::Context.run(a_reporter)
  end

  at_exit do
    reporter.time { run(reporter) }
    reporter.results
    exit false unless reporter.passed?
  end
end # Riot

class Object
  def context(description, &the_context)
    # reporter ||= Riot.reporter
    # reporter.time { Riot::Context.new(description, reporter, parent, &block) }
    Riot::Context.context(description, &the_context)
  end
end # Object
