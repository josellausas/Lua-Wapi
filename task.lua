local Model = require("lapis.db.model").Model
local Tasks = Model:extend("tasks")
local Targets = Model:extend("targets",{
	relations = {
    	{"contact", belongs_to = "contact"},
    	{"establishment", belongs_to = "establishment"}

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
	for i,t in pairs(myTasks) do
		if (t.target.type == "CONTACT") then
			t.target.contact = t.target.get_contact()
		else
			t.target.establishment = t.target.get_establishment()
		end
	end
			



	return myTasks
	
end

return task