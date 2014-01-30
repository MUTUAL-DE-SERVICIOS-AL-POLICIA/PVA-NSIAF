json.array!(@users) do |user|
  json.extract! user, :id, :code, :name, :post, :ci, :email, :password, :phone, :cellular
  json.url user_url(user, format: :json)
end
