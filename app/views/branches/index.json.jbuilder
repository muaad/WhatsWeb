json.array!(@branches) do |branch|
  json.extract! branch, :id, :address, :latitude, :longitude
  json.url branch_url(branch, format: :json)
end
