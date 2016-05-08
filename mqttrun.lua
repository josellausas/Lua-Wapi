local MQTTHandler = require("MQTTHandler")

-- Start listening on mqtt:
print("Trying to start MQTT handler")
-- Exit the loop if we error:
local error_message = nil

while (error_message == nil) do
  -- This is the loop mr.
  error_message = MQTTHandler:start()
  socket.sleep(1.0)  -- seconds
  -- print("MQTT alive")
end

if(error_message) then
	print(error_message)
end
