defmodule Dailyploy.MixProject do
  use Mix.Project

  def project do
    [
      app: :dailyploy,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Dailyploy.Application, []},
      extra_applications: [:logger, :runtime_tools, :calendar, :timex, :arc_ecto]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.9"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.6"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:comeonin, "~> 5.1.2"},
      {:bcrypt_elixir, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      {:guardian, "~> 1.0"},
      {:ecto_enum, "~> 1.3"},
      {:sendgrid, "~> 2.0"},
      {:calendar, "~> 0.17.5"},
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.5"},
      {:params, "~> 2.0"},
      {:nimble_csv, "~> 0.6"},
      {:csv, "~> 2.3"},

      # csv upload
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:poison, "~> 3.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
