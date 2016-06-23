#!/bin/bash
git add . && git commit --verbose; git push heroku master && heroku logs -t
#ohhh
echo "[31;43mDone deploying to heroku[0m"
echo ""
echo ""
