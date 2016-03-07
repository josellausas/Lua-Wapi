Creating a LuaWapi on Heroku
=============================

Setup a Heroku OpenResty
-------------------------

### Create Heroku Instance

Run the Command `$ heroku create --buildpack http://github.com/leafo/heroku-buildpack-lua.git`

### Create a rockspec file

Create a file `*.rockspec` (just one!) in the root directory. 

    -- app.rockspec
    -- These are my rocks.
    dependencies = {
        "luasocket",
        "lua-cjson",
        "https://raw.github.com/leafo/heroku-openresty/master/heroku-openresty-dev-2.rockspec",
        "https://raw.githubusercontent.com/leafo/moonscript/master/moonscript-dev-1.rockspec",
        "https://raw.githubusercontent.com/leafo/lapis/master/lapis-dev-1.rockspec",
        "https://raw.github.com/leafo/lua-date/master/date-dev-1.rockspec",
    }


### Get resolver ip

`cat /etc/resolv.conf`

### Create a nginx config file

Create a `nginx.conf` file :


Set the resolver ip in the file


## Create a Procfile

`web: lapis server heroku`



### Push and assign juice

`heroku scale web=1`


References
----------
- https://github.com/leafo/heroku-buildpack-lua
- http://leafo.net/lapis/
- https://github.com/leafo/heroku-lapis-example

