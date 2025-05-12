case Req.get("https://data.cdc.gov/api/views/25m4-6qqq/rows.json?accessType=DOWNLOAD", decode_body: false) do
  {:ok, %Req.Response{body: body, status: 200}} -> File.write!("profile/cdc.json", body)
end
case Req.get("https://edg.epa.gov/data.json", decode_body: false) do
  {:ok, %Req.Response{body: body, status: 200}} -> File.write!("profile/edg.json", body)
end
