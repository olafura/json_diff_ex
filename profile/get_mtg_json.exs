case Req.get("https://mtgjson.com/api/v5/ModernAtomic.json", decode_body: false) do
  {:ok, %Req.Response{body: body, status: 200}} -> File.write!("profile/ModernAtomic.json", body)
end
case Req.get("https://mtgjson.com/api/v5/LegacyAtomic.json", decode_body: false) do
  {:ok, %Req.Response{body: body, status: 200}} -> File.write!("profile/LegacyAtomic.json", body)
end
