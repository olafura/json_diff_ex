defmodule JsonDiffExTest do
  use ExUnit.Case, async: true
  doctest JsonDiffEx

  @speed_test System.get_env("SPEED") === "true"
  @big_json1 File.read!("test/big_json1.json")
  @big_json2 File.read!("test/big_json2.json")

  import JsonDiffEx

  def comparediff(s1, s2, diff_res) do
    j1 = Poison.decode!(s1)
    j2 = Poison.decode!(s2)
    case @speed_test do
      true -> assert diff(j1, j2) == diff_res
      false -> assert diff(j1, j2) == JsHelp.diff(s1, s2)
    end
  end

  def comparediff_patch(s1, s2, diff1) do
    j1 = Poison.decode!(s1)
    j2 = Poison.decode!(s2)
    case @speed_test do
      true -> assert patch(j1, diff1) == j2
      false ->
        assert patch(j1, diff(j1, j2)) == j2
    end
  end

  test "check basic diff" do
    s1 = ~s({"1": 1})
    s2 = ~s({"1": 2})
    res = %{"1" => [1, 2]}
    comparediff(s1, s2, res)
  end

  test "check array diff" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [1,2,4]})
    res = %{"1" => %{"2" => [4], "_2" => [3, 0, 0], "_t" => "a"}}
    comparediff(s1, s2, res)
  end

  test "check the same object" do
    s1 = ~s({"1": [1,2,3], "2": 1})
    j1 = Poison.decode!(s1)
    assert diff(j1, j1) == %{}
    # jsondiffpatch returns undefined
  end

  test "check object diff not changed" do
    s1 = ~s({"1": 1, "2": 2})
    s2 = ~s({"1": 2, "2": 2})
    res = %{"1" => [1, 2]}
    comparediff(s1, s2, res)
  end

  test "check array diff not changed" do
    s1 = ~s({"1": 1, "2": [1]})
    s2 = ~s({"1": 2, "2": [1]})
    res = %{"1" => [1, 2]}
    comparediff(s1, s2, res)
  end

  test "check array diff all changed" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [4,5,6]})
    res = %{"1" => %{"0" => [4], "1" => [5], "2" => [6], "_0" => [1, 0, 0], "_1" => [2, 0, 0], "_2" => [3, 0, 0], "_t" => "a"}}
    comparediff(s1, s2, res)
  end

#  jsondiffpatch does things a little different
#  test "check array diff reorder" do
#    s1 = ~s({"1": [1,2,3]})
#    s2 = ~s({"1": [3,2,1]})
#    res = %{"1" => %{"_0" => ["", 2, 3], "_2" => ["", 0, 3], "_t" => "a"}}
#    comparediff(s1, s2, res)
#  end

  test "check array diff delete first" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [2,3]})
    res = %{"1" => %{"_0" => [1, 0, 0], "_t" => "a"}}
    comparediff(s1, s2, res)
  end

 test "check array diff shift one" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [0,1,2,3]})
    res = %{"1" => %{"0" => [0], "_t" => "a"}}
    comparediff(s1, s2, res)
  end

  test "check object in array diff" do
    s1 = ~s({"1": [{"1":1}]})
    s2 = ~s({"1": [{"1":2}]})
    res = %{"1" => %{"0" => %{"1" => [1, 2]}, "_t" => "a"}}
    comparediff(s1, s2, res)
  end

  test "check object with muliple values in array diff" do
    s1 = ~s({"1": [{"1":1,"2":2}]})
    s2 = ~s({"1": [{"1":2,"2":2}]})
    res = %{"1" => %{"0" => %{"1" => [1, 2]}, "_t" => "a"}}
    comparediff(s1, s2, res)
  end

  test "check object with muliple values plus in array diff" do
    s1 = ~s({"1": [{"1":1,"2":2},{"3":3,"4":4}]})
    s2 = ~s({"1": [{"1":2,"2":2},{"3":5,"4":6}]})
    res = %{"1" => %{"0" => %{"1" => [1, 2]}, "1" => %{"3" => [3, 5], "4" => [4, 6]}, "_t" => "a"}}
    comparediff(s1, s2, res)
  end

  test "check one object in array diff" do
    s1 = ~s({"1": [1]})
    s2 = ~s({"1": [{"1":2}]})
    res = %{"1" => %{"0" => [%{"1" => 2}], "_0" => [1, 0, 0], "_t" => "a"}}
    comparediff(s1, s2, res)
  end

# Might be a bug in jsondiffpatch
#  test "check deleted value with object in array diff" do
#    s1 = ~s({"1": [1,{"1":1}]})
#    s2 = ~s({"1": [{"1":1}]})
#    res = %{"1" => %{"_0" => [1, 0, 0], "_t" => "a"}}
#    comparediff(s1, s2, res)
#  end

  test "check deleted value with object with change in array diff" do
    s1 = ~s({"1": [1,{"1":1}]})
    s2 = ~s({"1": [{"1":2}]})
    res = %{"1" => %{"0" => [%{"1" => 2}], "_0" => [1, 0, 0], "_1" => [%{"1" => 1}, 0, 0], "_t" => "a"}}
    comparediff(s1, s2, res)
  end

  test "check bigger diff" do
    s1 = @big_json1
    s2 = @big_json2
    res = %{"_id" => ["56353d1bca16dd7354045f7f", "56353d1bec3821c78ad14479"],
            "about" => ["Laborum cupidatat proident deserunt fugiat aliquip deserunt. Mollit deserunt amet ut tempor veniam qui. Nulla ipsum non nostrud ut magna excepteur nulla non cupidatat magna ipsum.\r\n",
            "Consequat ullamco proident anim sunt ipsum esse Lorem tempor pariatur. Nostrud officia mollit aliqua sit consectetur sint minim veniam proident labore anim incididunt ex. Est amet laboris pariatur ut id qui et.\r\n"],
            "address" => ["265 Sutton Street, Tioga, Hawaii, 9975", "919 Lefferts Avenue, Winchester, Colorado, 2905"], "age" => [21, 29], "balance" => ["$1,343.75", "$3,273.15"], "company" => ["RAMJOB", "ANDRYX"],
            "email" => ["eleanorbaxter@ramjob.com", "talleyreyes@andryx.com"], "eyeColor" => ["brown", "blue"], "favoriteFruit" => ["apple", "banana"], "gender" => ["female", "male"],
            "friends" => %{"0" => %{"name" => ["Larsen Sawyer", "Shelby Barrett"]}, "1" => %{"name" => ["Frost Carey", "Gloria Mccray"]}, "2" => %{"name" => ["Irene Lee", "Hopper Luna"]}, "_t" => "a"},
            "greeting" => ["Hello, Eleanor Baxter! You have 8 unread messages.", "Hello, Talley Reyes! You have 2 unread messages."], "guid" => ["809e01c1-b8c4-4d49-a9e7-204091cd6ae8", "b2b50dae-5d30-4514-82b1-26714d91e264"],
            "index" => [0, 1], "isActive" => [true, false], "latitude" => [-44.600585, 39.655822], "longitude" => [-9.257008, -70.899696], "name" => ["Eleanor Baxter", "Talley Reyes"],
            "phone" => ["+1 (876) 456-3989", "+1 (895) 435-3714"], "registered" => ["2014-07-20T11:36:42 +04:00", "2015-03-11T11:45:43 +04:00"]}
    comparediff(s1, s2, res)
  end

  test "check basic patch" do
    s1 = ~s({"1": 1})
    s2 = ~s({"1": 2})
    diff1 = %{"1" => [1, 2]}
    comparediff_patch(s1, s2, diff1)
  end

  test "check array patch" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [1,2,4]})
    diff1 = %{"1" => %{"2" => [4], "_2" => [3, 0, 0], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check array patch all changed" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [4,5,6]})
    diff1 = %{"1" => %{"0" => [4], "1" => [5], "2" => [6], "_0" => [1, 0, 0], "_1" => [2, 0, 0], "_2" => [3, 0, 0], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check array patch reorder" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [3,2,1]})
    diff1 = %{"1" => %{"_0" => ["", 2, 3], "_2" => ["", 0, 3], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check array patch delete first" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [2,3]})
    diff1 = %{"1" => %{"_0" => [1, 0, 0], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check array patch shift one" do
    s1 = ~s({"1": [1,2,3]})
    s2 = ~s({"1": [0,1,2,3]})
    diff1 = %{"1" => %{"0" => [0], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check array patch shift one inside" do
   s1 = ~s({"1": [1,2,3]})
   s2 = ~s({"1": [1,2,0,3]})
   diff1 = %{"1" => %{"3" => [0], "_t" => "a"}}
   comparediff_patch(s1, s2, diff1)
  end

  test "check object in array patch" do
    s1 = ~s({"1": [{"1":1}]})
    s2 = ~s({"1": [{"1":2}]})
    diff1 = %{"1" => %{"0" => %{"1" => [1, 2]}, "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check one object in array patch" do
    s1 = ~s({"1": [1]})
    s2 = ~s({"1": [{"1":2}]})
    diff1 = %{"1" => %{"0" => [%{"1" => 2}], "_0" => [1, 0, 0], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check deleted value with object with change in array patch" do
    s1 = ~s({"1": [1,{"1":1}]})
    s2 = ~s({"1": [{"1":2}]})
    diff1 = %{"1" => %{"0" => [%{"1" => 2}], "_0" => [1, 0, 0], "_1" => [%{"1" => 1}, 0, 0], "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end

  test "check if deleted key works" do
    s1 = ~s({"foo": 1})
    s2 = ~s({"bar": 3})
    diff1 = %{"bar" => [3], "foo" => [1, 0, 0]}
    comparediff_patch(s1, s2, diff1)
  end

  test "check if more than 10 in index works" do
    s1 = ~s({"cards": [{"foo1": true}, {"foo2": true}, {"foo3": true},
                       {"foo4": true}, {"foo5": true}, {"foo6": true},
                       {"foo7": true}, {"foo8": true}, {"foo9": true},
                       {"foo10": true}, {"foo11": true}, {"foo12": true}]})
    s2 = ~s({"cards": [{"foo1": true}, {"foo2": true}, {"foo3": true},
                       {"foo4": true}, {"foo5": true}, {"foo6": true},
                       {"foo7": true}, {"foo8": true}, {"foo9": true},
                       {"foo10": true}, {"foo11": true}, {"foo12": true}]})
    diff1 = %{"cards" => %{"12" => %{"foo11" => [true, false]}, "_t" => "a"}}
    comparediff_patch(s1, s2, diff1)
  end


  test "check bigger patch" do
    s1 = @big_json1
    s2 = @big_json2
    diff1 = %{"_id" => ["56353d1bca16dd7354045f7f", "56353d1bec3821c78ad14479"],
            "about" => ["Laborum cupidatat proident deserunt fugiat aliquip deserunt. Mollit deserunt amet ut tempor veniam qui. Nulla ipsum non nostrud ut magna excepteur nulla non cupidatat magna ipsum.\r\n",
            "Consequat ullamco proident anim sunt ipsum esse Lorem tempor pariatur. Nostrud officia mollit aliqua sit consectetur sint minim veniam proident labore anim incididunt ex. Est amet laboris pariatur ut id qui et.\r\n"],
            "address" => ["265 Sutton Street, Tioga, Hawaii, 9975", "919 Lefferts Avenue, Winchester, Colorado, 2905"], "age" => [21, 29], "balance" => ["$1,343.75", "$3,273.15"], "company" => ["RAMJOB", "ANDRYX"],
            "email" => ["eleanorbaxter@ramjob.com", "talleyreyes@andryx.com"], "eyeColor" => ["brown", "blue"], "favoriteFruit" => ["apple", "banana"], "gender" => ["female", "male"],
            "friends" => %{"0" => %{"name" => ["Larsen Sawyer", "Shelby Barrett"]}, "1" => %{"name" => ["Frost Carey", "Gloria Mccray"]}, "2" => %{"name" => ["Irene Lee", "Hopper Luna"]}, "_t" => "a"},
            "greeting" => ["Hello, Eleanor Baxter! You have 8 unread messages.", "Hello, Talley Reyes! You have 2 unread messages."], "guid" => ["809e01c1-b8c4-4d49-a9e7-204091cd6ae8", "b2b50dae-5d30-4514-82b1-26714d91e264"],
            "index" => [0, 1], "isActive" => [true, false], "latitude" => [-44.600585, 39.655822], "longitude" => [-9.257008, -70.899696], "name" => ["Eleanor Baxter", "Talley Reyes"],
            "phone" => ["+1 (876) 456-3989", "+1 (895) 435-3714"], "registered" => ["2014-07-20T11:36:42 +04:00", "2015-03-11T11:45:43 +04:00"]}
    comparediff_patch(s1, s2, diff1)
  end
end
