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
local t = os.time()
local blink_interval = 5.0 -- sec
local last_blink_time = t
local last_player_id = 0

local world = {}


-------------------------------------------------------------------------------
local function on_connect( event ) 
    print( "connect", event.peer:index() )
    world[ event.peer:index() ] = {}
end

-------------------------------------------------------------------------------
local function on_disconnect( event )
    print( "disconnect", event.peer:index() )
    world[ event.peer:index() ] = {}
end

-------------------------------------------------------------------------------
local function on_receive( event )
    t = os.time()
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

-------------------------------------------------------------------------------
print( "starting server", host_address )
while true do
    local event = host:service( 1 )
    if event then
        if event.type == "receive" then
            on_receive( event )
        elseif event.type == "connect" then
            on_connect( event )
        elseif event.type == "disconnect" then
            on_disconnect( event )
        else
            print( "unknown event.type", event.type )
        end
    end
end




