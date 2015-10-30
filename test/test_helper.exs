ExUnit.start()

defmodule JsHelp do

  def diff(s1, s2) do
    case System.cmd("nodejs", ["js/test_helper.js", s1, s2]) do
      {result, 0} -> Poison.decode!(result)
      {error, 1} -> error
    end
  end
end
