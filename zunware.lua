local lapis = require("lapis")
local config = require("lapis.config").get()

local app = lapis.Application()

app:enable("etlua")

app.layout = require ("views.layout")

app:get("index", "/", function(self)

	-- Renders default index
	return { render = "index" }
end)



lapis.serve(app)

