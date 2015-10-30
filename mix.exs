defmodule JsonDiffEx.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :json_diff_ex,
     version: @version,
     description: "Diff and patch for JSON in Elixir",
     package: package,
     docs: [source_ref: "v#{@version}", main: "JsonDiffEx"],
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Olafur Arason"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/olafura/json_diff_ex"}
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, "~> 1.5", only: :test},
     {:dogma, "~> 0.0", only: :dev},
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev}]
  end
end
