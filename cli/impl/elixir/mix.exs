defmodule SayableCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :sayable_cli,
      version: "0.5.0",
      elixir: "~> 1.14",
      deps: deps(),
      elixirc_options: [warnings_as_errors: true]
    ]
  end

  defp deps do
    [
      {:sayable_age, path: "../../../age/impl/elixir"},
      {:sayable_date, path: "../../../date/impl/elixir"},
      {:sayable_time, path: "../../../time/impl/elixir"},
      {:sayable_duration, path: "../../../duration/impl/elixir"}
    ]
  end
end
