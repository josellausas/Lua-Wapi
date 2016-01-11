
local MQTTHandler = require("MQTTHandler")
local pgmoon 	  = require("pgmoon")

-- Used for the database
local pg 		= pgmoon.new({
	host = "ec2-54-83-59-203.compute-1.amazonaws.com",
	user = "wddcthddvouvtr",
	password = "_EsJ9XVoYVSYXDWbUDOTQPdrph",
	database = "d2k28tn5s3orl5"
})


-- Start listening on mqtt:
local handler = MQTTHandler:start()




