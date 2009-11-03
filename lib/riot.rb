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

  def self.run(a_reporter=nil)
    Context.run(a_reporter || reporter)
  end

  at_exit do
    reporter.time { run(reporter) }
    reporter.results
    exit false unless reporter.passed?
  end unless Riot.silently?
end # Riot

class Object
  def context(description, &the_context)
    Riot::Context.context(description, &the_context)
  end
end # Object
