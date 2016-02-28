--[[ LLOrganization ]]
local Model = require("lapis.db.model").Model
local OrganizationModel = Model:extend("organizations", {
	timestamp = true
})

o = {}

local function decorateClass(obj)
	function obj:save()
		self:update("name")
	end
end

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

	decorateClass(instance)
	return instance
end


-- [[Returns the Organization with name]]
o.withName = function(name)
	local org = OrganizationModel:find({name = name})
	if(org == nil) then
		return nil
	end

	decorateClass(org)
	return org
end

return o