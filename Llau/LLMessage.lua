--[[
	LLMessage
	=========

]]

local os = require("os")

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
		inst.ayload 	= payload
		inst.timeStamp 	= os.time()

		return inst
	end

return m
