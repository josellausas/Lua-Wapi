#!/bin/bash
lapis build && git add . && git commit -m "Fast commit" && git push heroku master && heroku logs -t
#ohhh
