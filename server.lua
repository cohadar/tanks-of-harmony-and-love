-------------------------------------------------------------------------------
-- embedded game server for "Tanks of Harmony and Love"
-- can NOT be run as standalone Lua app!
-- TODO: figure out how to call this in love2d console mode!
-------------------------------------------------------------------------------
require "enet"
m_utils = require "utils"
m_tank = require "tank"
m_text = require "text"
m_ticker = require "ticker"
require "love.timer"

local tanks = {}
local tank_commands = {}
local client_ticks = {}

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
local function on_receive( event, server_tick )
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
        end        
    end    
    if server_tick % 3 == 0 then
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
    local mark = love.timer.getTime()
    m_ticker.init( mark )
    while true do
        local event = host:service( 0 )
        if event then
            if event.type == "receive" then
                on_receive( event, tick )
            elseif event.type == "connect" then
                on_connect( event )
            elseif event.type == "disconnect" then
                on_disconnect( host, event )
            else
                m_text.print( "ERROR: unknown event.type", event.type )
            end
        end
        mark = love.timer.getTime()
        while m_ticker.tick( mark ) do
            tick = tick + 1
            on_update( host, tick )
        end
    end
end

-------------------------------------------------------------------------------
-- TODO: better start/stop control for host
-------------------------------------------------------------------------------
channel = love.thread.getChannel( "server_channel" )
value = channel:demand()
start_server( value.host, value.port )






