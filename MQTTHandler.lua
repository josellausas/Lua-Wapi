-- MQTTHandler by Llau.
--[[
	Esto escucha mqtt y hace cosas. Usa PahoMQTT en lua
]]
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


local running = true

local function unwrapLuaPayload(msg)
	local unpackobj,err = cjson.decode(msg)

	if(err) then
		return msg
	else 
		return unpackobj
	end
end

-- Función que reacciona a los mensajes
local callback = function(topic, message)
	print("Topic: " .. topic .. ", message: " .. message)
	if string.find(topic, "v1/notify") then
		local json,err = cjson.decode(message)

		


		if err then
			print(err)
			local n = Notification.new(9, "Error: " .. message, "local")
			n:save()
		else
			local decoded = Llau:decode(base64.decode(json.msg))
			local n = Notification.new(json.severe, decoded, json.ip)
			n:save()
		end

	end

	if string.find(topic, "v1/register/") then
		local note = Notification.new(0, message, "new device")
		note:save()
	end

	if topic == "v1/subscribe/email" then
		local payload,err = cjson.decode(message)

		-- Creates a subsciber
		local subscriber = Subscriber.new(payload.email, payload.ip, payload.source)
		subscriber:save()

		-- Cretes a notification
		local note = Notification.new("0", "Subscribed: " .. subscriber.email .. " via " .. subscriber.source, payload.ip)
		note:save()
	end
		

	if (message == "llau-says-quit") then 
		running = false 
	end
end

-- Inicia el cliente MQTT y escucha para reaccionar a los diferentes mensajes
function h:start()
	local mqtt_client = nil

	print("Starting MQTT Handler by Llau...")

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

    

	while (error_message == nil and running) do
	  -- This is the loop mr.
	  error_message = mqtt_client:handler()
	  socket.sleep(1.0)  -- seconds
	  -- print("MQTT alive")
	end

	if (error_message == nil) then
		print("Cerrando MQTT")
	  mqtt_client:unsubscribe({"v1/#"})
	  mqtt_client:destroy()
	else
	  print("El ERROR: " .. error_message)
	
	 
	end

end

return h