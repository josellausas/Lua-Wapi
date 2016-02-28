local config
config = require("lapis.config").config
return config("heroku", function()
  port(os.getenv("PORT"))
  postgresql_url(os.getenv("DATABASE_URL"))
  return postgres(function()
    host("ec2-54-83-59-203.compute-1.amazonaws.com")
    user("wddcthddvouvtr")
    password("_EsJ9XVoYVSYXDWbUDOTQPdrph")
    return database("d2k28tn5s3orl5")
  end)
end)
