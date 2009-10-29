require 'teststrap'

context "nested context" do
  setup do
    ctx = Class.new(Riot::Context)
    ctx.description = "foo"
    ctx.setup { @pass_me_around = {:counter => 5} }
    ctx
  end # nested context
  
  context "having inner context with own setup" do
    setup do
      ctx = Class.new(topic)
      ctx.description = "baz"
      ctx.setup { topic[:counter] += 10 }
      ctx
    end
  
    should("chain context descriptions") { topic.full_description }.equals("foo baz")

    should("inherit parent context") do
      topic.new.run(Riot::NilReport.new)
    end.assigns(:pass_me_around, {:counter => 15})
  end

  context "having inner context without its own setup" do
    setup do
      ctx = Class.new(topic)
      ctx.description = "bum"
      ctx.new.run(Riot::NilReport.new)
    end

    asserts("parent setup is called") do
      topic
    end.assigns(:pass_me_around, {:counter => 5})

  end # inner context without its own setup
end # nested context
