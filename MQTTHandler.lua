-- MQTTHandler by Llau.
--[[
	Esto escucha mqtt y hace cosas. Usa PahoMQTT en lua
]]
local h = {}

local cjson     = require "cjson.safe"
local Crypto 	= require 'crypto'
local base64 	= require 'Llau.base64'
local config   	= require("lapis.config").get()
-- La configuración de nuestro cliente MQTT.
local mqtt_config = {
	host = "m10.cloudmqtt.com",
	port = "11915",
	user = "handler",
	password = "handlerquesito",
	offlinePayload = "Handler: offline",
	keepalive = 40,
}

config.postgres = {
    host = "ec2-54-83-59-203.compute-1.amazonaws.com",
    user = "wddcthddvouvtr",
    password = "_EsJ9XVoYVSYXDWbUDOTQPdrph",
    database = "d2k28tn5s3orl5"
}

local Llau 			= require("Llau.Llau")
local MQTT 			= require("mqtt")
local Notification 	= require("Llau.LLNotification")
local Subscriber    = require("Llau.LLSubscriber")

-- Running flag
local running = true



--[[local function unwrapLuaPayload(msg)
	local unpackobj,err = cjson.decode(msg)

	if(err) then
		return msg
	else 
		return unpackobj
	end
end]]

--[[ 
	Callback for Mqtt messages 
]]
local callback = function(topic, message)
	-- Log notifications here
	if string.find(topic, "v1/notify") then
		-- Decode the json
		local json,err = cjson.decode(message)

		-- Log as error if this is not coded correcty
		if err then
			-- Create a Llau notification with the error as message
			local n = Notification.new(9, "Error: " .. message, "local")
			-- Save the message to the database
			n:save()
		else
			-- Decrypt the message
			local decoded = Llau:decrypt(base64.decode(json.msg))
			-- Create a notification and save
			local n = Notification.new(json.severe, decoded, json.ip)
			n:save()
		end
	end

	-- Device registrations
	if string.find(topic, "v1/register/") then
		local note = Notification.new(0, message, "new device")
		note:save()
	end


	-- Email suscription
	if topic == "v1/subscribe/email" then
		local payload,err = cjson.decode(message)

		-- Creates a subsciber
		local subscriber = Subscriber.new(payload.email, payload.ip, payload.source)
		subscriber:save()

		-- Cretes a notification
		local note = Notification.new("0", "Subscribed: " .. subscriber.email .. " via " .. subscriber.source, payload.ip)
		note:save()
	end
		
	-- Emergency quit
	if (message == "llau-says-quit") then 
		-- Set the running flag
		running = false 
	end
end

-- Inicia el cliente MQTT y escucha para reaccionar a los diferentes mensajes
function h:start()
	-- Start clean mqtt
	local mqtt_client = nil

	-- Lazy instantiate mqtt
	if(mqtt_client == nil) then
		mqtt_client = MQTT.client.create(mqtt_config.host, mqtt_config.port, callback)
	end

	if(mqtt_client.connected == false) then
		-- Set the auth 
		mqtt_client:auth(mqtt_config.user, mqtt_config.password)
		-- Connect with last will, stick, qos = 2 and offline payload.
	    mqtt_client:connect("handler", "v1/status/handler", 2, 1, mqtt_config.offlinePayload)	
	    -- Post a connection message
	    mqtt_client:publish("v1/status/handler", "Handler: " .. mqtt_config.user .. " online")
	end

    -- Listen to all channels.
    mqtt_client:subscribe({"v1/#"})

    -- Exit the loop if we error:
    local error_message = nil

    -- Loop receive :)
	while (error_message == nil and running) do
	  -- This is the loop fruit
	  error_message = mqtt_client:handler()
	  socket.sleep(1.0)  -- seconds
	end

	-- If we broke because of an error
	if (error_message == nil) then
	  mqtt_client:unsubscribe({"v1/#"})
	  mqtt_client:destroy()
	else
	  print("El ERROR: " .. error_message)
	end
end

return h
