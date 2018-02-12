defmodule ApolloTracing.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :apollo_tracing,
      version: @version,
      elixir: "~> 1.5-rc",
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps()
    ]
  end

  defp package do
    [description: "Apollo Tracing middleware for Absinthe",
     files: ["lib", "mix.exs", "README*"],
     maintainers: ["Sikanhe"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/sikanhe/apollo-tracing-elixir"}]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.4.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
