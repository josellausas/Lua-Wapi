--[[
	LLauSystems Tests
	=================
]]

local lapis 	     = require("lapis")
local Model 		 = require("lapis.db.model").Model
local config 		 = require ("lapis.config").get()
local capture_errors = require("lapis.application").capture_errors
local respond_to     = require("lapis.application").respond_to
local mock_request 	 = require("lapis.spec.request").mock_request
local use_test_env   = require("lapis.spec").use_test_env

-- Instantiate the thing
local app = require("app")


describe("Llau Systems: ", function()
	describe("Lapis: ", function()
		it("has Lapis", function()
			assert.truthy(lapis)
		end)
		it("has Config", function()
			assert.truthy(config)
		end)
		it("has an index", function()
			local status, body = mock_request(app, "/")
			assert.same(200, status)
			assert.truthy(body)
		end)
	end)

	describe("Database: ", function()
		it("loads", function()
			assert.truthy(Model)
		end)
	end)

	describe("API", function()
		it("has /", function()
			local status, body = mock_request(app, "/")
			assert.same(200, status)
			assert.truthy(body)
		end)
		it("has /login", function()
			local status, body = mock_request(app, "/login")
			assert.same(200, status)
			assert.truthy(body)
		end)
		it("has /logout", function()
			local status, body = mock_request(app, "/logout")
			assert.same(200, status)
			assert.truthy(body)
		end)
		it("has /admin", function()
			local status, body = mock_request(app, "/admin")
			assert.same(200, status)
			assert.truthy(body)
		end)
		it("has /readme", function()
			local status, body = mock_request(app, "/readme")
			assert.same(200, status)
			assert.truthy(body)
		end)
	end)

	describe("Llau Lib: ", function()

	end)

	describe("Admin Dashboard: ", function()

	end)
end)

