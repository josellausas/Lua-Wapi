local km = {}

km.getCalendar = function(username)
	-- TODO: Query the database for the calendar and return it as json
	sampleJSON = {
		user = username,
		date = today
	}

	return {json=sampleJSON}
end


return km