big_json1 = Jason.decode!(File.read!("profile/ModernAtomic.json"), keys: :atoms)
big_json2 = Jason.decode!(File.read!("profile/LegacyAtomic.json"), keys: :atoms)

JsonDiffEx.diff(big_json1,big_json2)
