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

	return usr.name
	-- local assignent = calendarAssignments:find({user=theUser.id})
	-- local calendar = assignent:get_calendar()
	-- return calendar
end

km.getTasksJSON = function(self, usr)
	local theUser = users:find({username = usr})
	local Users 	= Model:extend("users")
	local Targets 	= Model:extend("targets")
	local Jornadas 	= Model:extend("jornadas")
	local Actions 	= Model:extend("actions")
	local Tasks 	= Model:extend("tasks")

	local myTasks = Tasks:select('where "user" = ? ', theUser.id)

	-- Prefetch the data to avoid hitting the DB too much.
	Targets:include_in( myTasks, "target",  {as = "target"})
	Jornadas:include_in(myTasks, "jornada", {as = "jornada"})
	Actions:include_in(myTasks,  "action",  {as="action"})


	print ("User: " .. theUser.name .. " has: " ..  #myTasks .. " tasks."   )


	local taskListJSON = {}
	for i,task in pairs(myTasks) do
		table.insert(taskListJSON, task)
	end

	return {json=taskListJSON}
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