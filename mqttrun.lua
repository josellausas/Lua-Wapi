local MQTTHandler = require("MQTTHandler")

-- Start listening on mqtt:
print("Trying to start MQTT handler")
-- Exit the loop if we error:
local error_message = nil

error_message = MQTTHandler:start()

if(error_message) then
	print(error_message)
end

print("Got to the end, wtf")
