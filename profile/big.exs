big_json1 = Poison.decode!(File.read!("profile/AllSets.json"))
big_json2 = Poison.decode!(File.read!("profile/AllSets-x.json"))

JsonDiffEx.diff(big_json1,big_json2)
