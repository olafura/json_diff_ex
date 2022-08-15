defmodule JsonDiffEx.Mixfile do
  use Mix.Project

  @version "0.6.7"

  def project do
    [
      app: :json_diff_ex,
      version: @version,
      description: "Diff and patch for JSON in Elixir",
      package: package(),
      docs: [source_ref: "v#{@version}", main: "JsonDiffEx"],
      test_coverage: [tool: Coverex.Task],
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def dialyzer do
    [
      plt_add_apps: [:mix, :ex_unit],
      check_plt: true
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Olafur Arason"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/olafura/json_diff_ex"}
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 4.0", only: [:dev, :test]},
      {:credo, "~> 1.5", only: :dev},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.24", only: :dev},
      {:coverex, "~> 1.5", only: :test},
      {:httpoison, "~> 1.8", only: :test},
      {:eep, git: "https://github.com/virtan/eep.git", only: :test},
      {:stream_data, "~> 0.5", only: :test},
      {:dialyxir, "~> 1.1", only: [:dev, :test]}
    ]
  end
end
