--[[
	LLMessage
	=========

]]

local os = require("os")

local m = {}

--[[ Creates and returns a new message instance ]]
m.new = function(sender, receiver, payload)

	local inst = {
		sender = nil,
		receiver = nil,
		timeStamp = nil,
		payload = ""
	}

	inst.sender 	= sender
	inst.receiver 	= receiver
	inst.payload 	= payload
	inst.timeStamp 	= os.time()


	function inst:getDate()
		local t = os.date("*t", self.timeStamp) 
		return t
	end

	return inst
end



return m
