--[[ LLEstablishment ]]
local EstablishmentModel = Model:extend("establishments", {
	timestamp = true
})
local e = {}


local function decorateClass(obj)
	function obj:save()
		self:update("address","latitude","longitude","name","organization")
	end
end


e.new = function(name, organization, latitude, longitude, address)
	local model = {
		address = nil,
		latitude = nil,
		longitude = nil,
		name = nil,
		organization = nil,
	}

	model.name = name
	model.organization = organization.id
	model.latitude = latitude
	model.longitude = longitude
	model.address = address

	local instance,e = EstablishmentModel:create(model)

	if(instance == nil) then
		print("Error en DB: ".. e)
		return nil
	end

	decorateClass(instance)

	return instance
end

e.withName = function(name)
	local u = Users:find({username = name})
	decorateClass(u)
	return u
end

e.withOrganization = function(organization)
	local u = EstablishmentModel:select('where "organiztion" = ?', organiztion.id)

	for i,v in pairs(u) do
		decorateClass(v)
	end

	return u
end



return e
