
local Model = require("lapis.db.model").Model
local Users = Model:extend("users", {
	timestamp = true
})

local t = {}

--[[ Adds the class functionality to the object ]]
local function decorateClass(obj)
	function obj:getName()
		return self.name
	end

	function obj:getEmail()
		return self.email
	end

	function obj:save()
		self:update("username","name","email","password")
	end
end

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

	decorateClass(dbInstance)
	
	-- Return the newly-freshly-made instance
	return dbInstance
end


--[[ Finds a user with Username ]]
t.withUsername = function(name)
	local u = Users:find({username = name})
	decorateClass(u)
	return u
end


return t