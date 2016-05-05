--[[ In charge of building the responses ]]
local Llau 			 = require("Llau.Llau")
local capture_errors = require("lapis.application").capture_errors
local respond_to     = require("lapis.application").respond_to
local csrf 		= require ("lapis.csrf")
local cjson     = require "cjson.safe"
local lapis_validate = require "lapis.validate"
local assert_valid 	 = lapis_validate.assert_valid
local yield_error 	 = require("lapis.application").yield_error
local cc = require("ansicolors")

local function ll(msg)
	local ccmsg = cc('%{red}[***LOG***]%{reset}\n\n%{blue}' .. msg .. '%{reset}\n\n')
	ngx.log(ngx.NOTICE, ccmsg)
end




local res = {}

local protectedLinkRequested = ""

--[[ MQTT API ]]
local function notifyMQTT(severe, msg, ipAddress)
	Llau:notify(severe,msg,ipAddress)
end

res.login = respond_to({
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
})

res.getApp = function(self)
	-- setSessionVars(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(0, "App downloaded!", forwardip)
	return { redirect_to="static/app-debug.apk", layout=false }
end

res.index = function(self)
	-- setSessionVars(self)
	self.webcontent = require("webcontent")
	return { render = "index" }
end


res.trap = function(self)
	local forwardip = self.req.headers["x-forwarded-for"] or "no-forward"
	notifyMQTT(3, "Robot hit honeypot!!!!", forwardip)
	return {render = "index" }
end


res.robots = function(self)
	return [[
	User-agent: *
	Disallow: /its-a-trap/ 
	Disallow: /tmp/
	Disallow: /getapp 
	Disallow: /admin
	Disallow: /console
	Disallow: /api
	]]
end

return res
