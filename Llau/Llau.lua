--------------------------------------------
-- Llau Task Manager
-- -----------------
-- This is the main interface for all the task functionality.
-- Any questions/comments: jose@josellausas.com
--
-- @author jose@josellausas.com
-- @copyright Zunware 2016. All rights reserved.
-- @module Llau
-- @alias ll
--------------------------------------------
local ll = {}

-- THIS HAS TO BE THE FIRST THING. DO NOT MOVE!
--- Lapis's config table
local config   	= require("lapis.config").get()
config.postgres = {
    host = "ec2-54-83-59-203.compute-1.amazonaws.com",
    user = "wddcthddvouvtr",
    password = "_EsJ9XVoYVSYXDWbUDOTQPdrph",
    database = "d2k28tn5s3orl5"
}

local Model  = require("lapis.db.model").Model
local LLTask = require("Llau.LLTask")
local LLUser = require("Llau.LLUser")
local Crypto = require 'crypto'
local cjson  = require "cjson.safe"
local mqtt   = require("mqtt")
local base64 = require "Llau.base64"

-- TODO: Check if this is still being used.
local pgmoon = require("pgmoon")
ll.config = {
	cipher = 'aes128',
	key = 'HhfewR*n#FFH)Dffatr3FD_DF-AD',
	iv = 157663
}

-- The Mqtt things
local mqtt_client = nil
local mqttconf 	= {
	host = "m10.cloudmqtt.com",
	port = "11915",
	user = "webserver",
	password = "webserverquesito",
	offlinePayload = "Webserver: offline",
	keepalive = 40,
}

-------------------------------------------------------------
-- Notifies something to the MQTT
--
-- @param self Reference to self
-- @param severe The severenes of the notification
-- @param msg The message to send
-- @strinng ipAddress Identifier for the message being sent
-----------------------------------------------------------
ll.notify = function(self, severe, msg, ipAddress)
	if mqtt_client == nil then
		mqtt_client = mqtt.client.create(mqttconf.host, mqttconf.port, nil)
		mqtt_client:auth(mqttconf.user, mqttconf.password)
	end

	if(mqtt_client.connected == false) then
		print("Connecting mqtt")
	-- Connect with last will, stick, qos = 2 and offline payload.
	    mqtt_client:connect("webserver", "v1/status/webserver", 2, 1, mqttconf.offlinePayload)

	    if(mqtt_client.connected == true) then
		    mqtt_client:publish("v1/status", "Webserver: " .. mqttconf.user .. " online")
		end
    end
   
    -- Build a JSON-style structure with an encrypted message
    local encodedEncrypted = base64.encode(self:encrypt(msg))
    local x = { severe = severe, msg = encodedEncrypted, ip=ipAddress }

   	-- Encode json
	local json,err = cjson.encode(x)

	if(mqtt_client.connected == true) then 
	    mqtt_client:publish("v1/notify/web", json )
	end
end

-----------------------------------------------------------
-- Returns a JSON object with all the tasks for the given user
-- 
-- @param self Self reference
-- @param usr The user to get the tasks for
--
-- @return **(Table)** A table of tasks
ll.getTasksJSON = function(self, usr)
	if usr == nil then return nil end
	
	-- TODO: Un-hardcode this
	local theUser = LLUser.withUsername(usr)
	
	-- Gets all the tasks for this user
	local myTasks = LLTask.allForUser(theUser)

	-- Converts to a JSON Object.
	local taskListJSON = {}
	for i,task in pairs(myTasks) do
		table.insert(taskListJSON, task)	-- Adds to the list
	end

	-- This is how Lapis returns JSON
	return {json=taskListJSON}
end


-------------------------------------------------------
-- Returns a list of Users
--
-- @return **(Table)** A table of Users
-------------------------------------------------------
ll.getUsersJSON = function(self)
	local allUsers = LLUser.listAll()

	local usersJSON = {}

	for i,user in pairs(allUsers) do
		table.insert(usersJSON, user)
	end

	return allUsers
end


-------------------------------------------------------
-- Returns the Calendar object for the given user
-- @param usr The user to get the calendar for
-- @return The calendar for the users
-------------------------------------------------------
ll.getCalendarForUser = function (self, usr)
	-- TODO: Implement this thing
	return usr.name
	-- local assignent = calendarAssignments:find({user=theUser.id})
	-- local calendar = assignent:get_calendar()
	-- return calendar
end



ll.getCalendarJSON = function(self, usrname)

	local theUser = users:find({username=usrname})

	if (theUser == nil) then
		-- Unauthorized 
		return { code=403 }
	end

	return {json=jsonCalendar}
end

ll.encrypt = function(self,msg)
	local res = Crypto.encrypt(self.config.cipher, msg, self.config.key, self.config.iv)
	return res
end

ll.decrypt = function(self, msg)
	local res = Crypto.decrypt(self.config.cipher, msg, self.config.key, self.config.iv)
	return res
end






return ll