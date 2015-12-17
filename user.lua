
local Model = require("lapis.db.model").Model
local Users = Model:extend("users")

local t = {}

t.withUsername = function(name)
	local theUser Users:find({username = name})

	return theUser
end


return t