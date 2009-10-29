require 'stringio'

module Riot
  class Report
    attr_reader :bad_results, :passes, :failures, :errors, :time_taken
    def initialize
      @bad_results = []
      @passes, @failures, @errors, @time_taken = 0, 0, 0, 0.0
    end

    def passed?; failures + errors == 0; end
    def assertions; passes + failures + errors; end

    def time(&block)
      @start = Time.now
      result = yield
      @time_taken += (Time.now - @start).to_f
      result
    end

    def process_assertion(assertion)
      if assertion.passed?
        passed
      else
        send((assertion.errored? ? :errored : :failed), assertion.result)
      end
    end

    def passed(description); @passes += 1; end
    
    def failed(description, failure)
      @failures += 1
      @bad_results << failure
    end

    def errored(description, error)
      @errors += 1
      @bad_results << error
    end

    def report_on_context(name); end

    def report(description, result)
      code, msg = result
      case code
      when :pass
        passed(description)
      when :fail
        failed(description, msg)
      when :error
        errored(description, msg)
      end
    end
  end # Report

  class NilReport < Report
    def results; end
    def time(&block); yield; end
  end # NilReport

  class StoryReport < Report
    def initialize(writer=nil)
      super()
      @writer ||= STDOUT
    end

    def report_on_context(name)
      @writer.puts(name)
    end

    def passed(description)
      super
      @writer.puts("  PASS: #{description}")
    end

    def failed(description, failure)
      super
      @writer.puts("  FAIL: #{description}: #{failure}")
    end

    def errored(description, error)
      super
      @writer.puts("  ERROR: #{description}: #{error}")
    end

    def results
      @writer.puts "\n\n"
      format = "%d assertions, %d failures, %d errors in %s seconds"
      @writer.puts format % [assertions, failures, errors, ("%0.6f" % time_taken)]
    end
  end

  class DotMatrixReport < Report
    def initialize(writer=nil)
      super()
      @writer ||= STDOUT
    end

    def passed(description)
      super && @writer.print('.')
    end

    def failed(description, failure)
      STDOUT.puts(failure.inspect)
      super && @writer.print('F')
    end

    def errored(description, error)
      STDOUT.puts(error.inspect)
      super && @writer.print('E')
    end

    def results
      @writer.puts "\n\n"
      # print_bad_results
      format = "%d assertions, %d failures, %d errors in %s seconds"
      @writer.puts format % [assertions, failures, errors, ("%0.6f" % time_taken)]
    end
  private
    def print_bad_results
      bad_results.each_with_index do |result, idx|
        @writer.puts format_result(idx + 1, result)
        @writer.puts "  " + result.backtrace.join("\n  ") if result.print_stacktrace?
        @writer.puts "\n"
      end
    end

    def format_result(idx, result) "#%d - %s" % [idx, result.to_s]; end
  end # TextReport
end # Riot
