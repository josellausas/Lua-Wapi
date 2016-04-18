--[[ 

	LLUser.lua
	==========
	
	@brief		A user abstraction.
]]


local Model  = require("lapis.db.model").Model
local crypto = require("crypto")

-- Create an object with the database
local UserModel = Model:extend("users", {
	-- Uses created_at and updated_at automatically
	timestamp = true
})

local cc = require("ansicolors")

local function ll(msg)
	local ccmsg = cc('%{red}[***LOG***]%{reset}\n\n%{blue}' .. msg .. '%{reset}\n\n')
	ngx.log(ngx.NOTICE, ccmsg)
end

-- Declare the module
local pack = {}


--[[

	decorateClass
	=============

	@brief		Gives an object the behaviors needed

]]

local function decorateClass(obj)
	function obj:save()
		-- TODO: Save the values to the database
		self:update("username", "email", "role", "hash")
	end

	function obj:getRole()
		-- TODO: Implement this
	end

	function obj:sendConfirmationEmail()
		-- TODO: Implement this
	end
end



--[[
	new
	===

	Creates a new user
]]
function pack.new(username, email, password)
	-- Fail if we have bad food
	if ( (not (username)) or 
		 (not (email)) or 
		 (not (password)) ) then
		return nil
	end

	-- The user class
	local userClass = {}

	-- Hash the password
	local passHash  = crypto.digest("sha256", password)

	-- Tell the things that are correct
	local goodUsername 	= true
	local goodPassword 	= true
	local goodEmail 	= true

	-- TODO: Check if email already exists
	if (goodUsername == false) then
		return nil
	end

	-- TODO: Check if username already exists
	if (goodPassword == false) then
		return nil
	end
	-- TODO: Check if password is good
	if (goodEmail == false) then
		return nil
	end

	-- Define the fields
	userClass.username = username
	userClass.email    = email
	userClass.role     = 2
	userClass.hash     = passHash
	userClass.first_name = username
	userClass.password = password


	-- Crete the database object
	local instance,e = UserModel:create(userClass)

	-- Check for error
	if(instance == nil) then
		ll("Error de base de datos: " .. e)
		return nil
	end

	-- Give it the functions
	decorateClass(instance)

	-- Return a newly created instance
	return instance
end



--[[
	Gets all the users
]]
function pack.listAll()
	-- Queries the database and returns a list of all the Users
	local allUsers = UserModel:select()

	for i,v in pairs(allUsers) do
		decorateClass(v)
	end

	return allUsers
end



--[[
	Gets a user with a username
]]
function pack.getWithUsername(user)
	local users = UserModel:select('where "username" = ? ', user)
	
	-- Returns nil if nothing is found
	if( #users < 1) then return nil end

	-- Add the functionality
	for i,v in pairs(users) do
		-- Give the data from the database functionality
		decorateClass(v)
		return v
	end
end


--[[
	getWithEmail
	============

	Gets a user with an email.
]]
function pack.getWithEmail(email)
	local users = UserModel:select('where "email" = ? ', email)

	-- None found!
	if(#users < 1) then
		return nil
	end
	
	-- Decorate and return the user found
	for i,v in pairs(users) do
		-- Give the data from the database functionality
		decorateClass(v)
		return v
	end
end


--[[*
	Returns the User with user and hash. Nil if bad
	@param user The user
	@param password The password
]]
function pack.authorizedEmailWithHash(email, passHash)
	local validEmail = false

	if (email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
	    validEmail = true
	else
	    print("INVALID EMAIL")                
	end

	if(validEmail == false) then return nil end
	-- Check in the users database
	local users = UserModel:select('where "email" = ? and "hash" = ?', email, passHash)
	
	-- Return nil if we found no one
	if( #users < 1) then 
		ngx.log(ngx.NOTICE, "[***] No user found")
		return nil
	end

	if( #users > 1) then
		ngx.log(ngx.NOTICE, "[***] More than one user found!")
		return nil
	end

	-- Add the functionality
	for i,v in pairs(users) do
		ngx.log(ngx.NOTICE, "[***] Found a valid USER!!!")
		-- Give the data from the database functionality
		decorateClass(v)
		return v
	end
end


--[[
	getWithUsernameAndPassword
	==========================

	@brief		Gets the user from the database with the password
]]
function pack.getWithUsernameAndPassword(user, pass)
	-- Hash the password
	local passHash = crypto.digest("sha256", pass)
	-- Check in the users database
	local users = UserModel:select('where "username" = ? and "hash" = ?', user, passHash)
	
	-- Return nil if we found no one
	if( #users < 1) then 
		ngx.log(ngx.NOTICE, "[***] No user found")
		return nil
	end

	if( #users > 1) then
		ngx.log(ngx.NOTICE, "[***] More than one user found!")
		return nil
	end

	-- Add the functionality
	for i,v in pairs(users) do
		ngx.log(ngx.NOTICE, "[***] Found a valid USER!!!")
		-- Give the data from the database functionality
		decorateClass(v)
		return v
	end
end


return pack
