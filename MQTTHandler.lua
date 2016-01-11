-- MQTTHandler by Llau.

--[[
	Esto escucha mqtt y hace cosas. Usa PahoMQTT en lua
]]

local MQTT 			= require("mqtt")
local lapis    		= require "lapis"
local config   		= require("lapis.config").get()
local Model  		= require("lapis.db.model").Model
local Notification 	= require("Llau.LLNotification")

local h = {}

-- La configuración de nuestro cliente MQTT.
local config = {
	host = "m10.cloudmqtt.com",
	port = "11915",
	user = "jose",
	password = "polo&xzaz",
	offlinePayload = "Handler: offline",
	keepalive = 40,
}

local mqtt_client = nil

local running = true

-- Función que reacciona a los mensajes
local callback = function(topic, message)
	print("Topic: " .. topic .. ", message: " .. message)

	if string.find(topic, "v1/notify") then
		-- Log this message to the database
		local note = LLNotification.new(0, message)
		note:save()
	end
		

	if (message == "llau-says-quit") then 
		running = false 
	end
end

-- Inicia el cliente MQTT y escucha para reaccionar a los diferentes mensajes
function h:start()


	print("Starting MQTT Handler by Llau...")

	if(mqtt_client == nil) then
		mqtt_client = MQTT.client.create(config.host, config.port, callback)
	end

	if(mqtt_client.connected == false) then
		-- Set the auth 
		mqtt_client:auth(config.user, config.password)
		-- Connect with last will, stick, qos = 2 and offline payload.
	    mqtt_client:connect("handler", "v1/status/handler", 2, 1, config.offlinePayload)	
	    -- Post a connection message
	    mqtt_client:publish("v1/status/handler", "Handler: " .. config.user .. " online")
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