--[[
	LLMessage
	=========

]]

local os = require("os")

-- The data structure of the message
local m = {
	sender = nil,
	receiver = nil,
	timeStamp = nil,
	payload = ""
}

m.new = function(sender, receiver, payload)
	m.sender = sender
	m.receiver = receiver
	m.payload = payload
	m.timeStamp = os.time()
end

return m
