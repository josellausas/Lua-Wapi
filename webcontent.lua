--[[ This describes a local website ]]
local webcontent = {
	title = "Llau Admin Systems",
	description = "An administration site",
	author = "Zunware",
	pages = {
		index = {
			header = "Intelligence in your pockets...",
			description = [[Data moves at light speed! Visualize and use IT in real time! or your're too slow. Smart decisions are made in real time with real data. "The power to run your business with the touch of a finger!"]],
			ios_url = "/#",
			android_url = "/static/app-debug.apk",
			carousel = {
				"/img/device-slider/screen01.png",
				"/img/device-slider/screen02.png",
				"/img/device-slider/screen01.png",
				"/img/device-slider/screen04.png"
			},
			social = {
				twitter = {
					url = "/#",
					class = "sb-twitter",
					icon = "fa fa-twitter",
					title = "Twitter",
					num = 13,
				},
				facebook = {
					url = "/#",
					class = "sb-facebook",
					icon = "fa fa-facebook",
					title = "Facebook",
					num = 37,
				},
			},
			section01 = {
				title = "Leverage the Internet of Things",
				subtitle = "control",
				img = "/img/home/screen01.jpg",
				video_url = "https://vimeo.com/33984473",
				button_lbl = "Watch a<br>Quick Demo",
				content01 = [[
				<p>Connecting your devices to the internet is easy and cheap in 2016. Gaining control and harvesting your own big data is an art.</p>
          		<p>Your mobile phone is now a full blown <a href="#">Command Center</a> ready for iOT. We have connected everything to make it easy for you to start using IoT.</p>
				]],
				content02 = "<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.</p>"
			},
			section02 = {
				title = "The Zunware APP",
				subtitle = "Anywhere",
				content01 = "<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco.</p>",
				

			},
		},
	},
}

return webcontent
