--[[
	This loads and serves our web app
]]

local lapis  = require "lapis"
local app 	 = require "web"

lapis.serve(app)
