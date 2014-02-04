json.array!(@auxiliaries) do |auxiliary|
  json.extract! auxiliary, :id, :code, :name, :account_id
  json.url auxiliary_url(auxiliary, format: :json)
end
