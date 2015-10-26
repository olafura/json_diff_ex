defmodule JsonDiffEx.Mixfile do
  use Mix.Project

  def project do
    [app: :json_diff_ex,
     version: "0.0.1",
     description: "Diff for JSON in Elixir",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, "~> 1.5"}]
  end
end
