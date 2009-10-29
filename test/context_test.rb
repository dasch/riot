require 'teststrap'

context "any context" do
  setup do
    Class.new(Riot::Context)
  end

  context "with a passing, failing, and erroring test" do
    setup do
      topic.should("a") { true }
      topic.should("b") { false }
      topic.should("c") { raise Exception, "blah" }
      topic.new.run(reporter = Riot::NilReport.new)
      reporter
    end

    asserts("passed test count") { topic.passes }.equals(1)
    asserts("failure count") { topic.failures }.equals(1)
    asserts("unexpected errors count") { topic.errors }.equals(1)
  end # with a passing, failing, and erroring test

  context "when running setup" do
    setup do
      topic.setup { "foo" }
      topic.new
    end
  
    asserts("topic is assigned to test as result of setup") { topic }.assigns(:topic, "foo")
    asserts("topic is and accessible method during test") { topic }.respond_to(:topic)
    asserts("calling topic in assertion returns the result from setup") { topic.topic }.equals("foo")
  end # when running setup

  asserts "will return assertion that returns topic as the actual" do
    topic.topic # :)
  end.kind_of(Riot::Assertion)
end # any context

# 
# Basic Context

context "a basic context" do
  setup do
    ctx = Class.new(Riot::Context)
    ctx.description = "foo"
    ctx.setup { @pass_me_around = {:counter => 0} }
    ctx.asserts("truthiness") { topic[:counter] += 1; true }
    ctx.asserts("more truthiness") { topic[:counter] += 1; true }
    ctx.new.run(Riot::NilReport.new)
  end

  # asserts("description is the same as to_s") { topic.class.to_s }.equals("foo")
  asserts("full description is the same as description with one context") do
    topic.class.full_description
  end.equals("foo")

  should("call setup once per context") { topic }.assigns(:pass_me_around, {:counter => 2})
end # a basic context
