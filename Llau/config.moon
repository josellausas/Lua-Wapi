
import config from require "lapis.config"

config "heroku", ->
  port os.getenv "PORT"
  postgresql_url os.getenv "DATABASE_URL"
  postgres ->
    host "ec2-54-83-59-203.compute-1.amazonaws.com"
    user "wddcthddvouvtr"
    password "_EsJ9XVoYVSYXDWbUDOTQPdrph"
    database "d2k28tn5s3orl5"

  