local lapis    = require "lapis"
local console  = require("lapis.console")
local config   = require("lapis.config").get()
local mqtt     = require("mqtt")
local markdown = require("markdown")
local pgmoon = require("pgmoon")
local pg = pgmoon.new({
	host = "ec2-54-83-59-203.compute-1.amazonaws.com",
    user = "wddcthddvouvtr",
    password = "_EsJ9XVoYVSYXDWbUDOTQPdrph",
    database = "d2k28tn5s3orl5"
})



-- Do the app config things
local app = lapis.Application()

app:enable("etlua")
app.layout = require "views.layout"		-- Sets the layout we are using.



-- Override what happens when there is a default route.
app.default_route = function ( self )
	
	-- There is no trailing slash removal at this step!!!
	ngx.log(ngx.NOTICE, "User 404 path " .. self.req.parsed_url_path)

	return lapis.Application.default_route(self)
end



-- Handle 404s
app.handle_404 = function( self )
	-- Returns the code 404
	return { status = 404, layout = false, "Not Found!" }
end

-- Handle errors
app.handle_error = function(self, err, trace)
	-- Logs to the nginx console
	ngx.log(ngx.NOTICE, "Lapis error: " .. err .. ": " .. trace)

	-- Handle the erros with Lapis internaly.
	lapis.Application.handle_error(self, err, trace)

	-- TODO: Crashlytics?
end


-- Figures out the html for the index.
local renderIndex = function()
	
	local theString = "<h2>version</h2> " .. require("lapis.version")

	return theString
end



-- Muestra una lista
app:get("/lista", function(self)
	
	local listaLoad = {}
	local countResults = 0

	-- Connect to the database
	pg:connect()
	-- Do the Query
	local res = pg:query("select * from posts")			
	pg:keepalive()

	-- Parse the Result
	for objectIndex, objectTable in ipairs( res ) do
		-- Make a count
		countResults = countResults+1
		-- Get the data from the object
		for key, value in pairs(objectTable) do
			
			if(key == "content") then
	   			table.insert(listaLoad, value)
	   		end
		end
	end		
	
	self.unalista = listaLoad

	return { render = "listaview" }
end)


local function generateJSON(self)
	-- This is a lua object that gets converted to JSON
	local demoLUAJSON = {
		Harris = "programmer",
		Chris = "CEO"
	}

	local response = {
		json = demoLUAJSON, 
		status = 200,
		content_type = "application/json"
	}

	return response
end

local function appDesctiption(self)

	local api = {
		Harris = "programmer",
		Chris = "CEO"
	}

	local response = {
		json = api, 
		status = 200,
		content_type = "application/json"
	}

	return response
end


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

-- INDEX
app:get("/", function(self)
	-- Make a test app.
	self.siteData = require("testData")
	self.title = "My Pro Dashboard"


	self.siteData.menuButtons = getMenuList()

	return { render = "dashboard" }
end)

app:get("/markdown", function(getReadme)

	readmeFile = io.open ("README.md", "r")
	contents = readmeFile:read("*all")

	return markdown(contents)
end)


app:get("/testjson", generateJSON)

-- Muestra la version
app:get("/version", renderIndex)
app:get("/api", appDesctiption)	




app:get("/dashboard", function(self)
	-- Make a test app.
	self.siteData = require("testData")
	self.title = "My Pro Dashboard"
	
	return { render = "dashboard" }
end)

-- The LUA CONSOLE FTW!!!
app:match("/console", function(self)
	-- Make a test app.
	self.siteData = require("testData")
	self.title = "My Pro Dashboard"
	return {render = "console"}
end)

local kimetrics = require("kimetrics")

app:get("/calendar", function(self) 
	
	-- TODO: Get username parameters from self
	local username = "josellausas"

	return kimetrics:getCalendarJSON(username)
end)

-- Serves a lapis web app.
lapis.serve(app)
