import config from require "lapis.config"
config "heroku", ->
  port os.getenv "PORT"
  postgresql_url os.getenv "DATABASE_URL"
  postgres ->
    host "ec2-54-83-59-203.compute-1.amazonaws.com"
    user "wddcthddvouvtr"
    password "_EsJ9XVoYVSYXDWbUDOTQPdrph"
    database "d2k28tn5s3orl5"
config "development", ->
  session_name "wapi_auth_access_44"
  secret "h3uYth77Kkfsd33"
  port "8080"
  postgresql_url os.getenv "DATABASE_URL"
  postgres ->
    host "127.0.0.1"
    user "baserestyuser"
    password "u&Uheb&#HJF2jweWJ"
    database "d32vvspmrh1dmj_local"

  