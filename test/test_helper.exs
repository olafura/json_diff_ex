ExUnit.start(exclude: [:failing])

defmodule JsHelp do
  def diff(s1, s2) do
    case System.cmd("node", ["js/test_helper.js", s1, s2]) do
      {result, 0} -> Poison.decode!(result)
      {error, 1} -> error
    end
  end

  def patch(s1, s2) do
    case System.cmd("node", ["js/patch_test_helper.js", s1, s2]) do
      {result, 0} -> Poison.decode!(result)
      {error, 1} -> error
    end
  end
end
