json.array!(@assets) do |asset|
  json.extract! asset, :id, :code, :description, :auxiliary_id, :user_id
  json.url asset_url(asset, format: :json)
end
