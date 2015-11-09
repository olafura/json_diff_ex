HTTPoison.start
case HTTPoison.get("http://www.usda.gov/data.json") do
  {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> File.write!("profile/usda.json", body)
end
case HTTPoison.get("https://edg.epa.gov/data.json") do
  {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> File.write!("profile/edg.json", body)
end
