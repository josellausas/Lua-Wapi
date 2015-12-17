
local Model = require("lapis.db.model").Model
local Users = Model:extend("users")

local t = {}

t.withUsername = function(name)
	return Users:find({username = name})
end


return t