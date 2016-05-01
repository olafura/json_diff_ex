big_json1 = Poison.Parser.parse!(File.read!("profile/AllSets.json"), keys: :atoms)
big_json2 = Poison.Parser.parse!(File.read!("profile/AllSets-x.json"), keys: :atoms)

JsonDiffEx.diff(big_json1,big_json2)
