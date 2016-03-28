#!/bin/bash
git add . && git commit --verbose; git push heroku master && heroku logs -t
#ohhh
