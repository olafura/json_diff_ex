defmodule JsonDiffEx.Mixfile do
  use Mix.Project

  @version "0.7.0"

  def project do
    [
      app: :json_diff_ex,
      version: @version,
      description: "Diff and patch for JSON in Elixir",
      package: package(),
      docs: [source_ref: "v#{@version}", main: "JsonDiffEx"],
      elixir: "~> 1.7",
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
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    resp = [
      {:credo, "~> 1.5", only: :dev},
      {:earmark, "~> 1.4", only: :dev},
      {:ex_doc, "~> 0.24", only: :dev},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:stream_data, "~> 1.0", only: :test},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false}
    ]

    if Version.match?(System.version(), ">= 1.13.0") do
      resp ++ [{:req, "~> 0.5.0", only: :test}]
    else
      resp
    end
  end
end
