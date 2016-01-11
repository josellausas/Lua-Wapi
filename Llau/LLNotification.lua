--[[
	LLNotification
	==============
]]

local os 	= require("os")
local Model = require("lapis.db.model").Model

local NotificationModel = Model:extend("notifications", {
	timestamp = true
})



local m = {} -- Declares the module.

--[[ Adds the Message functionality to the object ]]
local function decorateClass( obj )
	--[[ Returns the Lua date object ]]
	function obj:getDate()
		local t = os.date("*t", self.timeStamp) 
		return t
	end

	--[[ Returns the date as a readable string ]]
	function obj:getReadableDate()
		local t = os.date("*t", self.timeStamp)
		return ""..t.day.."/"..t.month.."/"..t.year
	end

	function obj:save()
		self:update("severity","payload","timestamp", "ip")
	end
end

--[[ Creates and returns a new message instance ]]
m.new = function(severe, payload, address)

	-- The message data structure reflects the DB Model.
	local model = {
		payload = "",
		severity = 0,
		timestamp = nil,
		ip = "No ip"
	}

	-- Data assignment
	-- TODO: Check for nils
	model.payload 		= payload
	model.timestamp 	= os.time()
	model.severity 		= severe
	model.ip 			= address or "No ip 2"

	local instance,e = NotificationModel:create(model)
	if(instance == nil) then
		print("Error de base de datos: " .. e)
		return nil
	end


	decorateClass(instance)

	return instance
end


--[[ Returns a list of all the messages destined for the given user ]]
m.allForSeverity = function(severity)
	-- Queries for all messages where receiver.id is the user
	local myMessages = NotificationModel:select('where "severity" = ? ', severity)
	
	-- Add the functionality
	for i,v in pairs(myMessages) do
		decorateClass(v)
	end

	return myMessages
end


return m
