--[[
		Lua Wapi Framework
		==================

		> Work in progress. Documentation soon.

]]

local lapis    	= require "lapis"
local config   	= require("lapis.config").get()
local mqtt     	= require("mqtt")
local markdown 	= require("markdown")
local pgmoon 	= require("pgmoon")
local console 	= require("lapis.console")
local Llau 		= require("Llau.Llau")
local Users     = require("Llau.LLUser")
local Messages  = require("Llau.LLMessage")
local csrf = require ("lapis.csrf")


local capture_errors = require("lapis.application").capture_errors
local respond_to     = require("lapis.application").respond_to

-- This user is hardcoded for now.
-- local josellausas = Users.withUsername("jose")


-- Used for the database
local pg 		= pgmoon.new({
	host = "ec2-54-83-59-203.compute-1.amazonaws.com",
	user = "wddcthddvouvtr",
	password = "_EsJ9XVoYVSYXDWbUDOTQPdrph",
	database = "d2k28tn5s3orl5"
})

-- Get a Lapis web app
local app = lapis.Application()

-- Enable EtLua templates
app:enable("etlua")

-- Set the default layout
app.layout = require "views.layout"		-- Sets the layout we are using.

--]]]]]]]]]]]]]]]]]]]]]]]]]]] WEB APP ]]]]]]]]]]]]]]]]]]]]]]





-- DEFAULT ROUTE
app.default_route = function ( self )	
	print("Entered default function")
	ngx.log(ngx.NOTICE, "Unknown path: " .. self.req.parsed_url.path)
	return lapis.Application.default_route(self)

end



-- 404
app.handle_404 = function( self )
	print("Found a 404")
	ngx.log(ngx.NOTICE, "Uknown path: " .. self.req.parsed_url.path)
	-- Returns the code 404
	return { status = 404, layout = false, "Not Found!" }
end




-- ERROR
--[[app.handle_error = function(self, err, trace)
	-- Logs to the nginx console
	ngx.log(ngx.NOTICE, "Lapis error: " .. err .. ": " .. trace)

	-- Handle the erros with Lapis internaly.
	lapis.Application.handle_error(self, err, trace)

	-- TODO: Crashlytics?
end]]




-- MENU LIST
local function getMenuList()
	pg:connect()
	local res = pg:query("select * from menu")
	pg:keepalive()

	local list = {}

	local count = 0;
	-- Parse the Result
	for objectIndex, objectTable in ipairs( res ) do
		
		count = count +1

		local button = {}
		-- Get the data from the object
		for key, value in pairs(objectTable) do

			if(key == "id") then
	   			button.id = value
	   		end

	   		if(key == "label") then
	   			button.label = value
	   		end

			if(key == "link") then
	   			button.link = value
	   		end

	   		if(key == "icon") then
	   			button.icon = value
	   		end

	   		if(key == "sortorder") then
	   			button.sortorder = value
	   		end

		end

		list[button.sortorder] = button
	end		

	return list
end















-- MARKDOWN PARSER
app:get("/readme", function(self)

	readmeFile = io.open ("README.md", "r")
	contents = readmeFile:read("*all")

	return markdown(contents)
end)


-- The LUA CONSOLE FTW!!!
app:match("/console", console.make({env="heroku"}))


--[[ RESTUFLL JSONS : ]]

-- CALENDAR
app:get("/calendar", function(self) 
	local josellausas = Users.withUsername("jose")
	-- TODO: Get username parameters from self
	return Llau:getCalendarJSON("josellausas")
end)




-- TASKS
app:get("list_tasks","/tasks", function(self)
	local josellausas = Users.withUsername("jose")
	local x = Llau:getTasksJSON("josellausas")
	return x
end)








app:get("/users", function(self)
	return Llau:getUsersJSON()
end)



responders = {}
responders.GET = function(self)
	print("Handling GET")
	return {status=200, layout=false, "OK"}
end

responders.POST = function(self)
	print("Handling POST")
	local josellausas = Users.withUsername("jose")
	local newMsg      = Messages.new(josellausas,josellausas, "Hola hola")

	return {redirect_to=self:url_for("index")}
end

app:match("/api/create-message", respond_to(responders) )

app:post("/api/new", capture_errors(function(self)
	print("handling post <<<<<")
	return {redirect_to = self:url_for("list_tasks")}
end))

-- INDEX
app:get("index","/", function(self)
	-- Make a test app.
	local josellausas = Users.withUsername("jose")
	
	self.siteData 	= require("testData")
	self.siteData.menuButtons = getMenuList()

	-- Fresh data from database:
	self.msgs 	= Messages.allForUser(josellausas)
	self.tasks 	= {}
	self.alerts = {}
	-- Render the dashboard by default
	return { render = "dashboard" }
end)


-- Serves a lapis web app.
lapis.serve(app)
