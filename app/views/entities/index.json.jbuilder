json.array!(@entities) do |entity|
  json.extract! entity, :id, :code, :name, :acronym
  json.url entity_url(entity, format: :json)
end
