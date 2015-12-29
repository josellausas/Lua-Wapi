local ll = {}

--[[
	Llau Task Manager
	-----------------
	
]]
local Model  = require("lapis.db.model").Model
local LLTask = require("Llau.LLTask")
local LLUser = require("Llau.LLUser")

ll.getTasksJSON = function(self, usr)
	local theUser = LLTask.withUsername("josellausas")
	local myTasks = LLUser.allForUser(theUser)

	local taskListJSON = {}
	for i,task in pairs(myTasks) do
		table.insert(taskListJSON, task)
	end

	return {json=taskListJSON}
end





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

	local userCalendar = self:getCalendarForUser(theUser)

	-- Allocate contigious memory
	local jsonCalendar = {
		startdate = nil,
		enddate = nil,
		loopdays = nil,
		events = {}
	}

	-- Build the user
	jsonCalendar.user = {
		username = theUser.username,
		name 	 = theUser.name,
		email 	 = theUser.email
	}




	return {json=jsonCalendar}
end




return km