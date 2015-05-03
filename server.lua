-------------------------------------------------------------------------------
-- game server for "Tanks of Harmony and Love"
-- standalone Lua app, not run by love2D engine
-- you will need luasocket installed, use https://luarocks.org/#quick-start
-- brew install enet || apt-get install enet
-- sudo luarocks install enet
-------------------------------------------------------------------------------
require "enet"

local host_address = "localhost:12345"
local host = enet.host_create( host_address )
print("starting server", host_address)

while true do
  local event = host:service(1)
  if event and event.type == "receive" then
    --print("Got message: ", event.data, event.peer)
    event.peer:send(event.data)
  end
end


