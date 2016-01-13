--[[ LLSubscriber by jose@josellausas.com ]]
local Model = require("lapis.db.model").Model
local SubscriberSQL = Model:extend("subscribers", {
	timestamp = true
})
local Subscriber = {}

local function decorateClass(obj)
	function obj:save()
		self:update("email","ip","source")
	end
end

function Subscriber.new(p_email, p_ip, p_source)
	local model = {
		email 	= p_email,
		ip 		= p_ip,
		source 	= p_source
	}

	-- Creates an intance of the object
	local instance,e = SubscriberSQL:create(model)

	if(instance == nil) then
		print("Error en DB: ".. e)
		return nil
	end

	-- Then decorate
	decorateClass(instance)

	return instance

end




return Subscriber

