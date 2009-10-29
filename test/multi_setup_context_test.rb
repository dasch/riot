require 'teststrap'

context "context with multiple setups" do
  setup do
    ctx = Class.new(Riot::Context)
    ctx.description = "foo"
    ctx.setup { @foo = "bar" }
    ctx.setup { @baz = "boo" }
    ctx
  end

  context "that define instance variables" do
    setup do
      topic.new.run(Riot::NilReport.new)
    end

    asserts("foo") { topic }.assigns(:foo, "bar")
    asserts("bar") { topic }.assigns(:baz, "boo")
  end # that define instance variables

  context "propagates to child contexts" do
    setup do
      ctx = Class.new(topic)
      ctx.description = "goo"
      ctx.setup { @goo = "car" }
      ctx.new.run(Riot::NilReport.new)
    end

    asserts("foo") { topic }.assigns(:foo, "bar")
    asserts("bar") { topic }.assigns(:baz, "boo")
    asserts("goo") { topic }.assigns(:goo, "car")
  end # in the parent of a nested context
end # multiple setups
