--[[
	LLMessage
	=========

	Abstracts a message that can be sent from one user to another.
	They must have a timestamp and a payload.

]]

local os 	= require("os")
local Model = require("lapis.db.model").Model
local MessageModel = Model:extend("message")


local m = {} -- Declares the module.

--[[ Creates and returns a new message instance ]]
m.new = function(sender, receiver, payload)

	-- The message data structure reflects the DB Model.
	local msgInstance = {
		sender = nil,
		receiver = nil,
		timeStamp = nil,
		payload = ""
	}

	-- Data assignment
	-- TODO: Check for nils
	msgInstance.sender 		= sender
	msgInstance.receiver 	= receiver
	msgInstance.payload 	= payload
	msgInstance.timeStamp 	= os.time()


	--[[ Returns the Lua date object ]]
	function msgInstance:getDate()
		local t = os.date("*t", self.timeStamp) 
		return t
	end

	--[[ Returns the date as a readable string ]]
	function msgInstance:getReadableDate()
		local t = os.date("*t", self.timeStamp)
		return ""..t.day.."/"..t.month.."/"..t.year
	end

	return msgInstance
end


--[[ Returns a list of all the messages destined for the given user ]]
m.allForUser = function(userObj)
	-- Queries for all messages where receiver.id is the user
	local myMessages = MessageModel:select('where "receiver" = ? ', userObj.id)
	return myMessages
end


return m
