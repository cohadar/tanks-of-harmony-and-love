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
local tanks = {}
local tank_commands = {}
local FPS = 1 / 60

-------------------------------------------------------------------------------
local function on_connect( event ) 
    print( "connect", event.peer:index(), os.time() )
    local gram = serpent.dump( { type = "index", index = event.peer:index() } ) 
    tanks[ event.peer:index() ] = m_tank.new()
    event.peer:send( gram )
end

-------------------------------------------------------------------------------
local function on_disconnect( host, event )
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
            tank_commands[ event.peer:index() ] = msg.tank_command
        else
            print( "unknown msg.type", msg.type, event.data )
        end
    end
end

-------------------------------------------------------------------------------
local function on_update( host, tick )
    --print( "update", serpent.dump(tanks) )
    for index, tank in pairs( tanks ) do 
        if tank_commands[ index ] ~= nil then
            m_tank.update( tank, tank_commands[ index ] )
        end        
    end    
    for index, tank in pairs( tanks ) do 
        local gram = serpent.dump( { type = "tank", index = index, tank = tank, tick = tick } )
        host:broadcast( gram ) 
    end
end

-------------------------------------------------------------------------------
function server_main()
    print( "starting server", host_address )
    local host = enet.host_create( host_address )
    local tick = 0
    local t = os.clock()
    while true do
        local event = host:service( 0 )
        if event then
            if event.type == "receive" then
                on_receive( event )
            elseif event.type == "connect" then
                on_connect( event )
            elseif event.type == "disconnect" then
                on_disconnect( host, event )
            else
                print( "unknown event.type", event.type )
            end
        end
        local temp = os.clock()
        if t + FPS < temp then
            t = temp
            tick = tick + 1
            on_update( host, tick )
        end
    end
end

-------------------------------------------------------------------------------
server_main()






