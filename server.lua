-------------------------------------------------------------------------------
-- game server for "Tanks of Harmony and Love"
-- can be run as standalone Lua app!
-- you will need luasocket installed, use https://luarocks.org/#quick-start
-- brew install enet || apt-get install enet
-- sudo luarocks install enet
-------------------------------------------------------------------------------
require "enet"
m_utils = require "utils"
m_tank = require "tank"
m_text = require "text"

local tanks = {}
local tank_commands = {}
local client_ticks = {}
local FPS = 1 / 60

-------------------------------------------------------------------------------
local function on_connect( event ) 
    m_text.print( "connect", event.peer:index(), os.time() )
    local gram = m_utils.pack{ type = "index", index = event.peer:index() }
    tanks[ event.peer:index() ] = m_tank.new()
    event.peer:send( gram, 0,  "unsequenced" )
end

-------------------------------------------------------------------------------
local function on_disconnect( host, event )
    m_text.print( "disconnect", event.peer:index() )
    tanks[ event.peer:index() ] = nil
    local gram = m_utils.pack{ type = "player_gone", index = event.peer:index() } 
    host:broadcast( gram )
end

-------------------------------------------------------------------------------
local function on_receive( event )
    t = os.time()
    msg = m_utils.unpack( event.data )
    if msg.type == "tank_command" then
        tank_commands[ event.peer:index() ] = msg.tank_command
        client_ticks[ event.peer:index() ] = msg.client_tick
    else
        m_text.print( "ERROR: unknown msg.type", msg.type, event.data )
    end
end

-------------------------------------------------------------------------------
local function on_update( host, server_tick )
    for index, tank in pairs( tanks ) do 
        if tank_commands[ index ] ~= nil then
            m_tank.update( tank, tank_commands[ index ] )
            tank_commands[ index ] = nil
        end        
    end    
    if server_tick % 6 == 0 then
    for index, tank in pairs( tanks ) do 
        local client_tick = client_ticks[ index ] 
        if client_tick == nil then
            client_tick = server_tick
            client_ticks[ index ] = server_tick 
        else
            client_ticks[ index ] = client_ticks[ index ] + 1    
        end
        local gram = m_utils.pack { type = "tank", index = index, tank = tank, server_tick = server_tick, client_tick = client_tick } 
        host:broadcast( gram, 0, "unsequenced" ) 
    end
    end
end

-------------------------------------------------------------------------------
local function start_server( host, port )
    server_address = host .. ":" .. port
    m_text.print( "starting server", server_address )
    local host = enet.host_create( server_address )
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
                m_text.print( "ERROR: unknown event.type", event.type )
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
if love then
    channel = love.thread.getChannel( "server_channel" )
    value = channel:demand()
    start_server( value.host, value.port )
else
    if arg[ 1 ] and arg[ 2 ] then
        start_server( arg[ 1 ], arg[ 2 ] )
    else
        print("Usage: lua server.lua <host> <port>")
    end
end






