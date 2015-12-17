local Model = require("lapis.db.model").Model
local Tasks = Model:extend("tasks")
local Targets = Model:extend("targets",{
	relations = {
    	{"contact", has_one = "contact"},
    	{"establishment", has_one = "establishment"}

  	}
})
local Jornadas = Model:extend("jornadas")
local Actions = Model:extend("actions")
local Contacts = Model:extend("contacts")
local Establishments = Model:extend("establishments")


local task = {}

task.allForUser = function(userObj)

	local myTasks = Tasks:select('where "user" = ? ', userObj.id)

	-- Prefetch the data to avoid hitting the DB too much.
	Targets:include_in( myTasks, "target",  {as = "target"})
	Jornadas:include_in(myTasks, "jornada", {as = "jornada"})
	Actions:include_in(myTasks,  "action",  {as="action"})

	local targets = {}
	for i,t in ipairs(myTasks) do
		table.insert(targets, t.target)
	end

	Contacts:include_in(targets, "contact", {as="contact", flip = true})
	Establishments:include_in(targets, "establishment", {as="establishment", flip=true})

	-- Reload them things.
	local targets = {}
	for i,t in ipairs(myTasks) do
		t.target = targets[i]
	end
	


	return myTasks
	
end

return task