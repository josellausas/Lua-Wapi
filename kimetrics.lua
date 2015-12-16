local km = {}

local lapis 
local Model = require("lapis.db.model").Model
local users 	= Model:extend("users")
-- local actions 	= Model:extend("actions")
-- local targets 	= Model:extend("targets")
-- local outcomes = Model:extend("outcomes", {
-- 	realations = {
-- 		{"users", belongs_to = "users" },
-- 		{"tasks", belongs_to = "tasks" },
-- 	}
-- })


-- local tasks  = Model:extend("tasks", {
-- 	relations = {
-- 		{"targets", belongs_to = "targets" },
-- 		{"action", belongs_to = "action" },
-- 		{"outcome", belongs_to = "outcome" },
-- 		{"users", belongs_to = "users" },
-- 		{"jornadas", belongs_to = "jornadas" },
-- 	}
-- })

-- local jornadas = Model:extend("jornadas", {
-- 	relations = {
-- 		{"calendars", belongs_to = "calendars" },
-- 		{"tasks", has_many = "tasks"}
-- 	}
-- })

-- local calendars = Model:extend("calendars", {
-- 	relations = {
-- 		{"jornadas", has_many = "jornadas"},
-- 		{"assignments", has_many = "assignments"}
-- 	}
-- })


-- local calendarAssignments = Model:extend("assignents", {
-- 	relations = {
-- 		{"users", 		belongs_to = "users"},
-- 		{"calendars", 	belongs_to = "calendars"},
-- 		{"tasks", 		has_many = "tasks"}
-- 	}
-- })




km.getCalendarForUser = function (self, usr)

	local theUser 	= users:find({username=usr})

	return theUser.name
	-- local assignent = calendarAssignments:find({user=theUser.id})
	-- local calendar = assignent:get_calendar()
	-- return calendar
end


km.getCalendarJSON = function(self, username)

	local jsonCalendar = {}

	local userCalendar = self.getCalendarForUser(self, username)

	jsonCalendar.name = userCalendar

	-- jsonCalendar = {
	-- 	name = userCalendar.name,
	-- 	startdate = userCalendar.startdate,
	-- 	enddate = userCalendar.enddate,
	-- 	loopdays = userCalendar.loopdays,
	-- 	events = {}
	-- }

	-- local calendarEvents = userCalendar:get_jornadas()
	-- for i,jornada in pairs(calendarEvents) do

	-- 	local jsonJornada = {}

	-- 	jsonJornada.calendarstart = jornada.calendarstart
	-- 	jsonJornada.calendarend   = jornada.calendarend
	-- 	jsonJornada.tasks = {}

	-- 	local tasks = jornada:get_tasks()

	-- 	for j, t in pairs(tasks) do
	-- 		local jsonTask = {}
	-- 		jsonTask.target 	= t.get_target()
	-- 		jsonTask.action 	= t.get_action()
			
	-- 		table.insert(jsonJornada.tasks, jsonTask)
	-- 	end

	-- 	table.insert(jsonCalendar.events, jsonJornada)
	-- end

	return {json=jsonCalendar}
end




return km