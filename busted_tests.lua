--[[ 
	Lua-Wapi Tests 
	==============
	
	Run with `busted busted_tests.lua`
]]

describe("Lua-Wapi", function()
	local clr = require 'trepl.colorize'
	local moduleName = "Lua-Wapi"
	local count = 0
	print("hey")

	local function ll(msg)
		print("\t" .. clr.red("[") .. clr.Blue(moduleName) .. clr.red("]") .. " - \"" .. msg .. "\"")
	end

	before_each(function()
		count = count + 1
		print ("[".. moduleName .. "]-> test #" .. count .. " started!")
	end)

	after_each(function()
		print ("[".. moduleName .. "]-> test #" .. count .. " finished!")
		print("")
	end)

	-- The global Lapis
	local lapis = nil
	
	describe("Setup", function()
		moduleName = "lapis"
		-- A freebie
		it("can tell the difference", function()
			ll("Hola lormal")
		end)

		-- Lapis
		it("can load lapis", function()
			lapis = require "lapis"
			assert.truthy(lapis)
		end)

		-- Get the config
		it("can load lapis config", function() 
			local config   	= require("lapis.config").get()
			assert.truthy(config)
		end)

		pending("can install missing dependencies", function()
			-- TODO

		end)
	end)

	-- The Llau library
	local Llau = nil
	describe("Llau Base", function() 
		moduleName = "Llau"
		it("can load LlauBase", function()
			-- Load my Library
			Llau = require("Llau.Llau")
			assert.truthy(Llau)
		end)

		it("can notify MasterQT", function()
			Llau:notify(0, "Testing with busted", "1.3.3.7")
		end)

		it("can encrypt and decrypt", function()
			local secretMessage = "Un mensaje ^#*nf48 *R#@BR Fb3*#m fd"
			local encrypted = Llau:encrypt(secretMessage)
			assert.truthy(encrypted)
			local decrypted = Llau:decrypt(encrypted)
			assert.truthy(decrypted)
			assert.are.same(decrypted, secretMessage)
		end)
	end)


	local Base64 = nil
	
	describe("Base64", function()
		moduleName = "Base64"
		it("can load Base64", function()
			Base64 = require("Llau.base64")
			assert.truthy(Base64)
		end)

		it("can encode and decode", function()
			local secret = "Un mensaje Muy screto que Tiene \'comillas\' ; señales y porcentajes"
			local encoded = Base64.encode(secret)
			assert.truthy(encoded)
			local decoded = Base64.decode(encoded)
			assert.truthy(decoded)
			assert.are.same(secret,decoded)

			local another = "Un dia Muy \'felix yo andaba aqui nomas así"
			encoded = Base64.encode(another)
			assert.truthy(encoded)
			decoded = Base64.decode(encoded)
			assert.truthy(decoded)
			assert.are.same(another,decoded)
		end)
	end)


end)

