HTTPoison.start
case HTTPoison.get("https://mtgjson.com/json/AllSets.json") do
  {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> File.write!("profile/AllSets.json", body)
end
case HTTPoison.get("https://mtgjson.com/json/AllSets-x.json") do
  {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> File.write!("profile/AllSets-x.json", body)
end
