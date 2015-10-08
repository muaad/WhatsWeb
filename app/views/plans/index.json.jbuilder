json.array!(@plans) do |plan|
  json.extract! plan, :id, :name, :price
  json.url plan_url(plan, format: :json)
end
