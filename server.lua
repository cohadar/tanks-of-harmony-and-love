-------------------------------------------------------------------------------
-- game server for "Tanks of Harmony and Love"
-- standalone Lua app, not run by love2D engine
-- you will need luasocket installed, use https://luarocks.org/#quick-start
-- brew install enet || apt-get install enet
-- sudo luarocks install enet
-------------------------------------------------------------------------------
require "enet"
serpent = require "serpent"
m_tank = require "tank"

local host_address = "localhost:12345"
local host = enet.host_create( host_address )
local tanks = {}
local ticks = {}
local sent_ticks = {}
local UPDATE_INTERVAL = 0.1 -- sec

-------------------------------------------------------------------------------
local function on_connect( event ) 
    print( "connect", event.peer:index(), os.time() )
    local gram = serpent.dump( { type = "index", index = event.peer:index() } ) 
    tanks[ event.peer:index() ] = m_tank.new()
    event.peer:send( gram )
end

-------------------------------------------------------------------------------
local function on_disconnect( event )
    print( "disconnect", event.peer:index() )
    tanks[ event.peer:index() ] = nil
    local gram = serpent.dump( { type = "player_gone", index = event.peer:index() } )
    host:broadcast( gram )
end

-------------------------------------------------------------------------------
local function on_receive( event )
    t = os.time()
    ok, msg = serpent.load( event.data )
    if ok then
        if msg.type == "tank_command" then
            print(serpent.line(msg.tank_command))
            local tank = tanks[ event.peer:index() ]
            m_tank.update( tank, msg.tank_command )
            ticks[ event.peer:index() ] = msg.tick
        else
            print( "unknown msg.type", msg.type, event.data )
        end
    end
end

-------------------------------------------------------------------------------
local function on_update()
    --print( "update", serpent.dump(tanks) )
    for index, tank in pairs( tanks ) do 
        if ticks[ index ] ~= sent_ticks[ index ] then
            local gram = serpent.dump( { type = "tank", index = index, tank = tank, tick = ticks[ index ] } )
            host:broadcast( gram ) 
            sent_ticks[ index ] = ticks[ index ]
        end
    end
end

-------------------------------------------------------------------------------
print( "starting server", host_address )
local t = os.time()
local last_update_time = t
while true do
    local event = host:service( 100 )
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
    on_update()
    -- t = os.time()
    -- if last_update_time + UPDATE_INTERVAL > t then
    --     last_update_time = t
    --     on_update()
    -- end
end




