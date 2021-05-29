defmodule Moonshine.TemplateGenerator do
  defmacro __before_compile__(env) do
    IO.inspect(env, label: "before compile")

    quote do
      @templates ["Foo"]
    end
  end
end
