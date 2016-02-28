local Model = require("lapis.db.model").Model

-- Armar los modelos segun las relaciones de la base de datos.
local Tasks   = Model:extend("tasks", {
	timestamp = true
})
local Targets = Model:extend("targets",{
	timestamp = true,
	relations = {
    	{"contact", has_one = "contact"},
    	{"establishment", has_one = "establishment"}
  	}
})
local Jornadas 	= Model:extend("jornadas", {
	timestamp = true
})
local Actions 	= Model:extend("actions", {
	timestamp = true
})
local Contacts 	= Model:extend("contacts", {
	timestamp = true
})
local Establishments = Model:extend("establishments", {
	timestamp = true
})


local taskModule = {} -- The Task Module!!!

--[[ Returns all the Tasks for the given user object ]]
taskModule.allForUser = function(userObj)

	-- Queries for all Tasks where userid is matched.	
	local myTasks = Tasks:select('where "user" = ? ', userObj.id)

	-- We need to specify the relationship data we want to pre-fetch. This avoids hitting the SQL too much.
	Targets:include_in( myTasks, "target",  {as = "target"})
	Jornadas:include_in(myTasks, "jornada", {as = "jornada"})
	Actions:include_in( myTasks,  "action", {as="action"})


	local targets = {} -- List that stores all the targets
	
	-- Grabs all the targets for this TaskList
	for i,t in ipairs(myTasks) do
		-- Add the target to the list
		table.insert(targets, t.target)
	end

	-- Specify the pre-fetch
	Contacts:include_in(targets, "contact", {as="contact"})
	Establishments:include_in(targets, "establishment", {as="establishment"})

	-- Reload them things.
	local targets = {}


	for i,t in ipairs(myTasks) do
		t.target = targets[i]
	end
	
	return myTasks
end

return taskModule