-------------------------------------------------------------------------------
-- game server for "Tanks of Harmony and Love"
-- standalone Lua app, not run by love2D engine
-- you will need luasocket installed, use https://luarocks.org/#quick-start
-- brew install enet || apt-get install enet
-- sudo luarocks install enet
-------------------------------------------------------------------------------
require "enet"
local serpent = require "serpent"

local host_address = "localhost:12345"
local host = enet.host_create( host_address )
print("starting server", host_address)
local t = os.time()
local blink_interval = 5.0 -- sec
local last_blink_time = t

while true do
  local event = host:service(1)
  if event and event.type == "receive" then
  	t = os.time()
  	print( "zz", t )
  	if last_blink_time + blink_interval < t then
  		last_blink_time = t
  		ok, gram = serpent.load( event.data )
  		if ok then
  			-- randomize tank location
  			gram.x, gram.y = math.random( 16*64 ), math.random( 12*64 )
  			print( "blink", gram.x, gram.y )
  			event.peer:send( serpent.dump(gram) )
  		end
    end
  end
end


