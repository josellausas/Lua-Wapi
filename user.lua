
local Model = require("lapis.db.model").Model
local Users = Model:extend("users")

local user = {}



function user.findWithUsername(name)

	local theUser Users:find({username = name})

	return theUser
end


return user