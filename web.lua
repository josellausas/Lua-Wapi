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
local csrf 		= require ("lapis.csrf")
local cjson     = require "cjson"

local mqtt_client = nil
local mqttconf 	= {
	host = "m10.cloudmqtt.com",
	port = "11915",
	user = "webserver",
	password = "webserverquesito",
	offlinePayload = "Webserver: offline",
	keepalive = 40,
}


local capture_errors = require("lapis.application").capture_errors
local respond_to     = require("lapis.application").respond_to

--[[ Serializa a lua table into a string ]]
local function serialize(theTable, name, skipnewlines, depth)
	local val = theTable
    skipnewlines = skipnewlines or false
    depth = depth or 0
    local tmp = string.rep(" ", depth)
    if name then tmp = tmp .. name .. " = " end
    if type(val) == "table" then
        tmp = tmp .. "{"
        for k, v in pairs(val) do
            tmp =  tmp .. serialize(v, k, skipnewlines, depth + 1) .. "," .. " "
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end
    return tmp
end


--[[ MQTT API ]]
local function notifyMQTT(severe, msg, ipAddress)
	if mqtt_client == nil then
		mqtt_client = mqtt.client.create(mqttconf.host, mqttconf.port, nil)
		mqtt_client:auth(mqttconf.user, mqttconf.password)
	end

	if(mqtt_client.connected == false) then
		print("Connecting mqtt")
	-- Connect with last will, stick, qos = 2 and offline payload.
	    mqtt_client:connect("webserver", "v1/status/webserver", 2, 1, mqttconf.offlinePayload)
	    mqtt_client:publish("v1/status", "Webserver: " .. mqttconf.user .. " online")
   end
    
    print("Publishing to mqtt")

    local x = { severe = severe, msg = msg, ip=ipAddress }


    mqtt_client:publish("v1/notify/admin", cjson.encode( x ) )
end


--[[ Email API ]]
local function registerEmail(theemail, clientip, sourceURL)
	if mqtt_client == nil then
		mqtt_client = mqtt.client.create(mqttconf.host, mqttconf.port, nil)
		mqtt_client:auth(mqttconf.user, mqttconf.password)
	end

	if(mqtt_client.connected == false) then
		print("Connecting mqtt")
	-- Connect with last will, stick, qos = 2 and offline payload.
	    mqtt_client:connect("webserver", "v1/status/webserver", 2, 1, mqttconf.offlinePayload)
	    mqtt_client:publish("v1/status", "Webserver: " .. mqttconf.user .. " online")
   end
    
    print("Publishing to mqtt")

    local sendWrap = { email=theemail, ip=clientip, source=sourceURL }
    mqtt_client:publish("v1/subscribe/email", cjson.encode(sendWrap) )
end



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



--[[404]]
app.handle_404 = function( self )
	print("Found a 404")
	ngx.log(ngx.NOTICE, "Uknown path: " .. self.req.parsed_url.path)
	-- Returns the code 404
	return { status = 404, render="error404", layout=false }
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
app:get("readme","/readme", function(self)

	readmeFile = io.open ("README.md", "r")
	contents = readmeFile:read("*all")

	return markdown(contents)
end)



-- The LUA CONSOLE FTW!!!
app:match("/console", console.make({env="heroku"}))





app:match("/subscribe/*", respond_to({
  GET = function(self)
    return { render = true }
  end,
  POST = function(self)
  	-- Grabs the ip
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	-- Grabs the email
	local email 	= self.params.EMAIL

	-- Checks for valid email
	if not (email == nil) then		
		if (email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
			-- Good email
		    registerEmail(email, forwardip, "web")
		else
			-- Bad email
		    notifyMQTT(3, "Bad email subscribe: " .. self.params.EMAIL , forwardip)            
		end
	end
  	
  	-- Redirects user
    return { redirect_to = self:url_for("index") }
  end
}))


--[[ RESTUFLL JSONS : ]]

--[[ Calendar API ]]
app:get("/calendar", function(self) 
	local josellausas = Users.withUsername("jose")
	-- TODO: Get username parameters from self
	return Llau:getCalendarJSON("josellausas")
end)


--[[ Tasks API ]]
app:get("list_tasks","/tasks", function(self)
	local josellausas 	= Users.withUsername("jose")
	local jsonData 		= Llau:getTasksJSON("josellausas")
	if not jsonData then return "" end
	return jsonData
end)


--[[ Users API ]]
app:get("/users", function(self)
	return Llau:getUsersJSON()
end)


--[[ Messages API]]
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


--[[ Web administration ]]
app:get("admin", "/admin", function(self)

	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(0,"Accessed admin!", forwardip)

	local josellausas 	= Users.withUsername("jose")
	self.siteData 		= require("testData")
	self.siteData.menuButtons = getMenuList()

	-- Fresh data from database:
	self.msgs 	= Messages.allForUser(josellausas)
	self.tasks 	= {}
	self.alerts = {}
	return {render="dashboards.default",layout="adminlayout"}
end)

--[[ Download the app ]]
app:get("getapp", "/getapp", function(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(0, "App downloaded!", forwardip)
	return { redirect_to="static/app-debug.apk", layout=false }
end)

--[[ Web INDEX re-route]]
app:get("/index", "/index.html", function(self)
	return {render = "index" }
end)

--[[ Web INDEX ]]
app:get("index","/", function(self)
	return { render = "index" }
end)

--[[ A nice honeypot ]]
app:get("its-a-trap", "/its-a-trap", function(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(3, "Robot hit honeypot!!!!", forwardip)
	return {render = "index" }
end)

-- [[ Serves the app ]]
app:get("llaubase", "/ios/llaubase")


--[[ Serve the webapp ]]
lapis.serve(app)	-- Serves a lapis web app.
