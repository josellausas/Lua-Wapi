-- MQTTHandler by Llau.

--[[
	Esto escucha mqtt y hace cosas. Usa PahoMQTT en lua
]]

local MQTT = require("mqtt")

local h = {}

-- La configuración de nuestro cliente MQTT.
local config = {
	host = "m10.cloudmqtt.com",
	port = "11915",
	user = "serverclient",
	password = "HYD*3bfh3",
	offlinePayload = "offline",
}

-- Función que reacciona a los mensajes
local callback = function(topic, message)
	print("Topic: " .. topic .. ", message: " .. message)
	ngx.log(ngx.NOTICE, "Topic: " .. topic .. ", message: " .. message)
end

-- Inicia el cliente MQTT y escucha para reaccionar a los diferentes mensajes
function h:start()
	print("Starting MQTT Handler by Llau...")

	local mqtt_client = MQTT.client.create(config.host, config.port, callback)

	-- Set the auth 
	mqtt_client:auth(config.user, config.password)
	-- Connect with last will, stick, qos = 2 and offline payload.
    mqtt_client:connect("Wapi", "status/handler", 2, 1, config.offlinePayload)
    -- Listen to all channels.
    mqtt_client:subscribe({"#"})

    -- Exit the loop if we error:
    local error_message = nil

	while (error_message == nil) do
	  -- This is the loop mr.
	  error_message = mqtt_client:handler()
	  socket.sleep(1.0)  -- seconds
	end

	if (error_message == nil) then
	  mqtt_client:unsubscribe({args.topic})
	  mqtt_client:destroy()
	else
	  print(error_message)
	  -- Log to nginx
	  ngx.log(ngx.NOTICE, "MQTTHandler [ERROR]:" .. error_message)
	end

end

return h