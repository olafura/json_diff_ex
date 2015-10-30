defmodule JsonDiffExTest do
  use ExUnit.Case, async: true
  doctest JsonDiffEx

  import JsonDiffEx

  def comparediff(s1, s2) do
    j1 = Poison.decode!(s1)
    j2 = Poison.decode!(s2)
    assert diff(j1, j2) == JsHelp.diff(s1, s2)
  end

  test "check basic diff" do
    s1 = ~s({"1": 1})
    s2 = ~s({"1": 2})
    comparediff(s1, s2)
  end

  test "check array diff" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [1,2,4]})
    comparediff(s1, s2)
  end

  test "check array diff all changed" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [4,5,6]})
    comparediff(s1, s2)
  end

#  jsondiffpatch does things a little different
#  test "check array diff reorder" do
#    s1 = ~s({"1": [1,2,3]})
#    s2 = ~s({"1": [3,2,1]})
#    comparediff(s1, s2)
#  end

  test "check array diff delete first" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [2,3]})
    comparediff(s1, s2)
  end

 test "check array diff shift one" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [0,1,2,3]})
    comparediff(s1, s2)
  end

  test "check object in array diff" do
    s1 = ~s({"1": [{"1":1}]})
    s2 = ~s({"1": [{"1":2}]})
    comparediff(s1, s2)
  end

  test "check one object in array diff" do
    s1 = ~s({"1": [1]})
    s2 = ~s({"1": [{"1":2}]})
    comparediff(s1, s2)
  end

# Might be a bug in jsondiffpatch
#  test "check deleted value with object in array diff" do
#    s1 = ~s({"1": [1,{"1":1}]})
#    s2 = ~s({"1": [{"1":1}]})
#    comparediff(s1, s2)
#  end

  test "check deleted value with object with change in array diff" do
    s1 = ~s({"1": [1,{"1":1}]})
    s2 = ~s({"1": [{"1":2}]})
    comparediff(s1, s2)
  end

end
