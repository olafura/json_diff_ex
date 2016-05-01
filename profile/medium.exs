big_json1 = Poison.Parser.parse!(File.read!("profile/usda.json"), keys: :atoms)
big_json2 = Poison.Parser.parse!(File.read!("profile/edg.json"), keys: :atoms)

JsonDiffEx.diff(big_json1,big_json2)
