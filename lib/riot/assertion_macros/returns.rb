module Riot
  # Asserts that the result of the test returns the expected value. Using the +==+ operator to assert
  # equality.
  #   asserts("#name") { topic.name }.returns("John")
  class ReturnsMacro < AssertionMacro
    register :returns

    def evaluate(actual, expected)
      if expected == actual
        pass new_message.returns(expected)
      else
        fail expected_message(expected).not(actual)
      end
    end
  end
end
