local km = {}

local Model = require("lapis.db.model").Model
local KLTask = require("task")
local KLUser = require("user")

km.getTasksJSON = function(self, usr)
	local theUser = KLUser.withUsername("josellausas")
	local myTasks = KLTask.allForUser(theUser)

	local taskListJSON = {}
	for i,task in pairs(myTasks) do
		table.insert(taskListJSON, task)
	end

	return {json=taskListJSON}
end





km.getCalendarForUser = function (self, usr)

	return usr.name
	-- local assignent = calendarAssignments:find({user=theUser.id})
	-- local calendar = assignent:get_calendar()
	-- return calendar
end




km.getCalendarJSON = function(self, usrname)

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