local ll = {}

--[[
	Llau Task Manager
	-----------------
	This is the main interface for all the task functionality.
	Any questions/comments: jose@josellausas.com

	All rights reserved.
	
]]
local Model  = require("lapis.db.model").Model
local LLTask = require("Llau.LLTask")
local LLUser = require("Llau.LLUser")
local Crypto = require 'crypto'

ll.config = {
	cipher = 'aes128',
	key = 'HhfewR*n#FFH)Dffatr3FD_DF-AD',
	iv = 157663
}


--[[ Returns a JSON object with all the tasks for the given user]]
ll.getTasksJSON = function(self, usr)
	if usr == nil then return nil end
	
	-- TODO: Un-hardcode this
	local theUser = LLUser.withUsername(usr)
	
	-- Gets all the tasks for this user
	local myTasks = LLTask.allForUser(theUser)

	-- Converts to a JSON Object.
	local taskListJSON = {}
	for i,task in pairs(myTasks) do
		table.insert(taskListJSON, task)	-- Adds to the list
	end

	-- This is how Lapis returns JSON
	return {json=taskListJSON}
end





--[[ Returns a list of Users ]]
ll.getUsersJSON = function(self)
	local allUsers = LLUser.listAll()

	local usersJSON = {}

	for i,user in pairs(allUsers) do
		table.insert(usersJSON, user)
	end

	return {json=allUsers}
end



--[[ Returns the Calendar object for the given user ]]
ll.getCalendarForUser = function (self, usr)

	return usr.name
	-- local assignent = calendarAssignments:find({user=theUser.id})
	-- local calendar = assignent:get_calendar()
	-- return calendar
end



ll.getCalendarJSON = function(self, usrname)

	local theUser = users:find({username=usrname})

	if (theUser == nil) then
		-- Unauthorized 
		return { code=403 }
	end

	return {json=jsonCalendar}
end

ll.encrypt = function(self,msg)
	local res = Crypto.encrypt(self.config.cipher, msg, self.config.key, self.config.iv)
	return res
end

ll.decrypt = function(self, msg)
	local res = Crypto.decrypt(self.config.cipher, msg, self.config.key, self.config.iv)
	return res
end




return ll