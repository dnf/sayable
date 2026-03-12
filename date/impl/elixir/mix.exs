defmodule SayableDate.MixProject do
  use Mix.Project

  def project do
    [
      app: :sayable_date,
      version: "0.5.0",
      elixir: "~> 1.14",
      deps: [],
      elixirc_options: [warnings_as_errors: true]
    ]
  end
end
