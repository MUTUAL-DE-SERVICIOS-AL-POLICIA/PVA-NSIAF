json.array!(@buildings) do |building|
  json.extract! building, :id, :code, :name, :entity_id
  json.url building_url(building, format: :json)
end
