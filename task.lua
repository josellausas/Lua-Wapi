local Model = require("lapis.db.model").Model
local Tasks = Model:extend("tasks")
local Targets = Model:extend("targets")
local Jornadas = Model:extend("jornadas")
local Actions = Model:extend("actions")


local task = {}

task.getTasksForUser = function(userObj)

	local myTasks = Tasks:select('where "user" = ? ', userObj.id)

	-- Prefetch the data to avoid hitting the DB too much.
	Targets:include_in( myTasks, "target",  {as = "target"})
	Jornadas:include_in(myTasks, "jornada", {as = "jornada"})
	Actions:include_in(myTasks,  "action",  {as="action"})

	return myTasks
	
end

return task