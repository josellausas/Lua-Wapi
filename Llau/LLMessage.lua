--[[
	LLMessage
	=========

	Abstracts a message that can be sent from one user to another.
	They must have a timestamp and a payload.

]]

local os 	= require("os")
local Model = require("lapis.db.model").Model
local MessageModel = Model:extend("message", {
	timestamp = true
})


local m = {} -- Declares the module.

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
		self:update("sender","receiver","timestamp","payload")
	end
end

--[[ Creates and returns a new message instance ]]
m.new = function(sender, receiver, payload)

	-- The message data structure reflects the DB Model.
	local model = {
		sender = nil,
		receiver = nil,
		timestamp = nil,
		payload = ""
	}

	-- Data assignment
	-- TODO: Check for nils
	model.sender 		= sender.id
	model.receiver 		= receiver.id
	model.payload 		= payload
	model.timestamp 	= os.time()

	local instance,e = MessageModel:create(model)
	if(instance == nil) then
		print("Error de base de datos: " .. e)
		return nil
	end


	decorateClass(instance)

	return instance
end


--[[ Returns a list of all the messages destined for the given user ]]
m.allForUser = function(userObj)
	-- Queries for all messages where receiver.id is the user
	local myMessages = MessageModel:select('where "receiver" = ? ', userObj.id)

	-- Add the functionality
	for i,v in pairs(myMessages) do
		decorateClass(v)
	end

	return myMessages
end


return m
