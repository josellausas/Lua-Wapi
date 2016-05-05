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
local LLUser     = require("Llau.LLUser")
local Messages  = require("Llau.LLMessage")
local csrf 		= require ("lapis.csrf")
local cjson     = require "cjson.safe"
local lapis_validate = require "lapis.validate"
local assert_valid 	 = lapis_validate.assert_valid
local yield_error 	 = require("lapis.application").yield_error

-- Used for the logging ing
local protectedLinkRequested = ""

local cc = require("ansicolors")

local function ll(msg)
	local ccmsg = cc('%{red}[***LOG***]%{reset}\n\n%{blue}' .. msg .. '%{reset}\n\n')
	ngx.log(ngx.NOTICE, ccmsg)
end

local function setSessionVars(sess)
	sess.webcontent = require("webcontent")
	-- This is necessary for internal linking
	sess.rootURL = ngx.var.scheme .. "s://" .. ngx.var.host
end


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

-- Get a Lapis web app
local app = lapis.Application()

-- Enable EtLua templates
app:enable("etlua")

-- Set the default layout
app.layout = require "views.layout"		-- Sets the layout we are using.



--[[ MQTT API ]]
local function notifyMQTT(severe, msg, ipAddress)
	Llau:notify(severe,msg,ipAddress)
end

-- Runs before all
app:before_filter(function(self)
	ll("Before filter running")
	-- This is importante. Do not remove!
	setSessionVars(self)
	
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	
	-- Check for session
	if self.session.current_user_id == nil then
		ll("Redirecting to login")
		-- Send to login so they do the things
		protectedLinkRequested = "admin"
		self:write({redirect_to=self:url_for("login")})
	end
end)

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


    local json,err = cjson.encode(sendWrap)
    mqtt_client:publish("v1/subscribe/email", json )
end

local function checkForAuth(self, requestedURL)
	-- Check for session
	if self.session.current_user_id == nil then
		ll("Has no permission, need to auth first")
		-- Send to login so they do the things
		protectedLinkRequested = requestedURL
		-- return {redirect_to=self:url_for("auth")}
		return{status=401, layout=false, "Unauthorized, authorize first."}
	else 
		return nil
	end
end

-- [[ DEFAULT ROUTE ]]
app.default_route = function ( self )
	setSessionVars(self)
	print("Entered default function")
	ngx.log(ngx.NOTICE, "Unknown path: " .. self.req.parsed_url.path)
	return lapis.Application.default_route(self)
end



--[[ 404 ]]
app.handle_404 = function( self )
	setSessionVars(self)
	ngx.log(ngx.NOTICE, "Uknown path: " .. self.req.parsed_url.path)
	
	-- Returns the code 404
	return { status = 404, render="error404", layout=false }
end


--[[ ERROR Handler ]]
app.handle_error = function(self, err, trace)
	setSessionVars(self)
	-- Logs to the nginx console
	ll("Lapis error: " .. err .. ": " .. trace)

	-- Handle the erros with Lapis internaly.
	lapis.Application.handle_error(self, err, trace)

	-- TODO: Notifiy the server of an error here
end

-- [[MENU LIST]]
-- Used for the database
local pg 		= pgmoon.new({
	host = "ec2-54-83-59-203.compute-1.amazonaws.com",
	user = "wddcthddvouvtr",
	password = "_EsJ9XVoYVSYXDWbUDOTQPdrph",
	database = "d2k28tn5s3orl5"
})
local function getMenuList()
	-- A dynamic menu.
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

	   		if(key == "sortorder") then button.sortorder = value end
		end

		list[button.sortorder] = button
	end		

	return list
end

-- MARKDOWN PARSER
app:get("readme","/readme", function(self)
	-- Shows a readme file with markdown
	readmeFile = io.open ("README.md", "r")
	contents = readmeFile:read("*all")

	-- Return the parsed HTML
	return markdown(contents)
end)

-- Handle email subscriptions
app:match("/subscribe/*", respond_to({
  GET = function(self)
	  
    return { render = true }
  end,
  POST = function(self)
  	-- setSessionVars(self)
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


app:match("auth", "/api/auth", respond_to({
	GET = function(self)
		-- setSessionVars(self)
		self.thetok = csrf.generate_token(self)
		
		if self.session.current_user_id == nil then
			ll("Has no permission, need to auth first")
			-- Send to login so they do the things
			protectedLinkRequested = requestedURL
			-- return {redirect_to=self:url_for("auth")}
			return{status=401, layout=false, "Unauthorized, authorize first."}
		end


		return {status=200, layout=false, json={msg = "Hola Auth Token"}}
	end,
	POST = capture_errors(function(self)
		-- TODO: Implement this
		-- local success, err = csrf.assert_token(self)
		--[[
		if(success == nil) then
			ll("CSRF Fail!")
			ll(err)
		end
		]]
		-- Continue if good
		assert_valid(self.params, {
			{"user", exists = true, min_length = 4, max_length = 128},
			-- {"email", is_email = true, max_length = 128},
			{"pass", exists = true,  min_length = 4, max_length = 128}
		})

		local user = self.params.user
		-- Should come in the form of a hash
		local pass = self.params.pass 

		-- Attempt to get the thing good
		local userObj = LLUser:authorizedEmailWithHash(user, pass)
		if(userObj == nil) then
			-- Not authorized
			ll("Is not authorized")
			local responseJSON = {
				msg = "Unauthorized"
			}
			return {status=401, layout=false, json="Bad"}
		else
			-- Authorize the session with username as token
			self.session.current_user_id = user.username
			ll("is authorized :)")
		    
		    --do authorized things here
			if(protectedLinkRequested == "" or protectedLinkRequested == nil) then
				-- Default login location
				ll("Redirecting to default location")
				-- setSessionVars(self)
				return {status=200, layout=false, json={msg = "Hola Auth Token"}}
			else
				ll("Redirect to : " .. self:url_for(protectedLinkRequested))
				return {redirect_to = self:url_for(protectedLinkRequested)}
			end
		end
	end)
}))



--[[ Tasks API ]]
app:get("list_tasks","/tasks", function(self)
	-- setSessionVars(self)
	local josellausas 	= LLUser.getWithUsername("jose")
	local jsonData 		= Llau:getTasksJSON("josellausas")
	if not jsonData then return "" end
	return jsonData
end)


--[[ Users API ]]
--[[app:get("/users", function(self)
	setSessionVars(self)
	return Llau:getUsersJSON()
end)]]
app:match("apiusers","/api/users", capture_errors(respond_to({
	GET = function(self)
		-- setSessionVars(self)

		local noAuth = checkForAuth(self, "apiusers")
		if noAuth then
			return noAuth
		end
		
		local jsonToReturn = Llau:getUsersJSON()
	    return {status=200, layout=false, json=jsonToReturn}
	end,	
	POST = function(self)
		-- setSessionVars(self)
		
		-- Yes this is how I do it.
		local noAuth = checkForAuth(self, "apiusers")
		if noAuth then
			return noAuth
		end
		
		-- Continue if good
		assert_valid(self.params, {
			{"user", exists = true, min_length = 4, max_length = 128},
			-- {"email", is_email = true, max_length = 128},
			{"pass", exists = true,  min_length = 4, max_length = 128}
		})

		--TODO: Implement a users api interface
		local user = self.params.user
		-- Should come in the form of a hash
		local pass = self.params.pass 

		local jsonToReturn = Llau:getUsersJSON()
	    return {status=200, layout=false, json=jsonToReturn}
	end,
})))



--[[ Messages API]]
responders = {}
responders.GET = function(self)
	-- setSessionVars(self)
	print("Handling GET")
	return {status=200, layout=false, "OK"}
end
responders.POST = function(self)
	-- setSessionVars(self)
	print("Handling POST")
	local josellausas = LLUser.getWithUsername("jose")
	local newMsg      = Messages.new(josellausas, josellausas, "Hola hola")
	return {redirect_to=self:url_for("index")}
end
app:match("/api/create-message", respond_to(responders) )


app:get("logout", "/logout", function(self)
	-- setSessionVars(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	self.session.current_user_id=nil
	notifyMQTT(0,"Logged out", forwardip)
end)


app:match("adminsection", "/admin/:section", respond_to({
	GET = function(self)
		-- setSessionVars(self)
		
		ll("Getting admin")
		local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"

		notifyMQTT(0,"Attempt to access admin admin!", forwardip)
		
		-- Check for session
		if self.session.current_user_id == nil then
			ll("Redirecting to login")
			-- Send to login so they do the things
			protectedLinkRequested = "admin"
			return {redirect_to=self:url_for("login")}
		end

		-- Only allows my user to get in here
		if self.session.current_user_id == "jose" then
			ll("Session is good")
			
			notifyMQTT(0,"Accessed admin with my acct!", forwardip)
			-- TODO check account permission here
			local josellausas 	= LLUser.getWithUsername("jose")
			
			if(josellausas == nil) then
				notifyMQTT(9, "Error al cargar usario", forwardip)
			else
			    ll("Jose exists!")
			end

			-- The site data
			self.siteData 		= require("testData")
			self.siteData.menuButtons = getMenuList()

			-- Fresh data from database:
			self.msgs 	= Messages.allForUser(josellausas)
			self.tasks 	= {}
			self.alerts = {}

			return {render=self.params.section ,layout="adminlayout"}
		else
			ll("Very weird login")
			-- Sesion was awkward
			notifyMQTT(9, "Very weird login", forwardip)
		end


		-- If we get here we dont have permission
		return {redirect_to=self:url_for("index")}
	end,
}))


--[[ Web administration ]]
app:match("admin", "/admin", respond_to({
	GET = function(self)
		-- setSessionVars(self)
		ll("Getting admin")
		local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
		notifyMQTT(0,"Attempt to access admin admin!", forwardip)
		-- Check for session
		if self.session.current_user_id == nil then
			ll("Redirecting to login")
			-- Send to login so they do the things
			protectedLinkRequested = "admin"
			return {redirect_to=self:url_for("login")}
		end

		-- Only allows my user to get in here
		if self.session.current_user_id == "jose" then
			ll("Session is good")
			
			notifyMQTT(0,"Accessed admin with my acct!", forwardip)
			-- TODO check account permission here
			local josellausas 	= LLUser.getWithUsername("jose")
			
			if(josellausas == nil) then
				notifyMQTT(9, "Error al cargar usario", forwardip)
			else
			    ll("Jose exists!")
			end

			-- The site data
			self.siteData 		= require("testData")
			self.siteData.menuButtons = getMenuList()

			-- Fresh data from database:
			self.msgs 	= Messages.allForUser(josellausas)
			self.tasks 	= {}
			self.alerts = {}

			return {render="dashboards.default",layout="adminlayout"}
		else
			ll("Very weird login")
			-- Sesion was awkward
			notifyMQTT(9, "Very weird login", forwardip)
		end


		-- If we get here we dont have permission
		return {redirect_to=self:url_for("index")}
	end,
}))

app:match("login", "/login", respond_to({
	GET = function(self)
		-- setSessionVars(self)
		self.thetok = csrf.generate_token(self)
		return {render = true}
	end,
	POST = capture_errors(function(self)
		ll("Posted login!")
		local success, err = csrf.assert_token(self)

		if(success == nil) then
			ll("CSRF Fail!")
			ll(err)
		end

		assert_valid(self.params, {
			{"username", exists = true, min_length = 4, max_length = 128},
			-- {"email", is_email = true, max_length = 128},
			{"password", exists = true,  min_length = 4, max_length = 128}
		})

		-- Attempt to get a user from the database
		local user = LLUser.getWithUsernameAndPassword(self.params.username, self.params.password)
		-- User should exits for us to continue
		if(not (user == nil) ) then
			-- The user is found!
			ll("Found! " .. user.username)
			
			-- Set this as the current session
			self.session.current_user_id = user.username

			-- Redirect to the protected page
			if(protectedLinkRequested == "" or protectedLinkRequested == nil) then
				-- Default login location
				ll("Redirecting to default location")
				-- setSessionVars(self)
				return {redirect_to = self:url_for("admin")}
			else
				ll("Redirect to : " .. self:url_for(protectedLinkRequested))
				return {redirect_to = self:url_for(protectedLinkRequested)}
			end
		else 
			ll("Invalid User no user found!!!")
		    -- No login
		    yield_error("Invalid username/password")
		    return {redirect_to = self:url_for("index")}
		end

	end)
}))




--[[ Download the app ]]
app:get("getapp", "/getapp", function(self)
	-- setSessionVars(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(0, "App downloaded!", forwardip)
	return { redirect_to="static/app-debug.apk", layout=false }
end)

--[[ Web INDEX re-route]]
app:get("/index", "/index.html", function(self)
	-- setSessionVars(self)
	return {render = "index" }
end)

--[[ Web INDEX ]]
app:get("index","/", function(self)
	-- setSessionVars(self)
	self.webcontent = require("webcontent")
	return { render = "index" }
end)

--[[ A nice honeypot ]]
app:get("its-a-trap", "/its-a-trap", function(self)
	-- setSessionVars(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(3, "Robot hit honeypot!!!!", forwardip)
	return {render = "index" }
end)


-- [[ Serves the app ]]
app:get("/robots", "/robots.txt", function(self)
	return [[
	User-agent: *
	Disallow: /its-a-trap/ 
	Disallow: /tmp/
	Disallow: /getapp 
	Disallow: /admin
	Disallow: /console
	Disallow: /api
	]]
end)

app:match("/console", console.make({env="heroku"}))



--[[ Serve the webapp ]]
return app
