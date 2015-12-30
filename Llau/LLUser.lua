
local Model = require("lapis.db.model").Model
local Users = Model:extend("users")

local t = {}

--[[ Creates a new instance of a User ]]
t.new = function(uname, name, email, pass)
	
	-- This models the DB
	local model = {
		username = nil,
		name = nil,
		email = nil,
		password = nil
	}

	-- Assign the data
	model.username 	= uname
	model.name 		= name
	model.email 	= email
	model.password 	= pass


	-- Crete it in the database:
	local dbInstance,e = Users:create(model)

	if(dbInstance == nil) then
		-- This indicates an error in the database
		print("Error de Base de datos: " .. e)
		return nil
	end


	function dbInstance:getName()
		return self.name
	end

	function dbInstance:getEmail()
		return self.email
	end

	function dbInstance:save()
		self:update("username","name","email","password")
	end
	-- Return the newly-freshly-made instance
	return dbInstance
end


--[[ Finds a user with Username ]]
t.withUsername = function(name)
	return Users:find({username = name})
end


return t