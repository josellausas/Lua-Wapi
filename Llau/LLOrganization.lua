--[[ LLOrganization ]]
local Model = require("lapis.db.model").Model
local OrganizationModel = Model:extend("organizations", {
	timestamp = true
})

o = {}

o.new = function(name)
	-- This needs to match the database
	local model = {
		name = nil
	}

	-- Set the data to the model.
	model.name = name

	-- Create an instance in the database
	local instance,e = OrganizationModel:create(model)
	if(instance == nil) then
		print("Error de base de datos: " .. e)
		return nil
	end

	function instance:save()
		self:update("name")
	end

	return instance
end


-- [[Returns the Organization with name]]
o.withName = function(name)
	return OrganizationModel:find({name = name})
end

return o