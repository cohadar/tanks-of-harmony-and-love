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

-------------------------------------------------------------------------------
local function on_connect( event ) 
    local index = event.peer:index()
    m_text.print( "connect", index, os.time() )
    local gram = m_utils.pack{ type = "index", index = index }
    tanks[ index ] = m_tank.new()
    tank_commands[ index ] = m_tank.newCommand()
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
    else
        m_text.print( "ERROR: unknown msg.type", msg.type, event.data )
    end
end

-------------------------------------------------------------------------------
local function on_update()
    for index, tank in pairs( tanks ) do 
        tank_command = tank_commands[ index ]
        m_tank.update( tank, tank_command )
        tank_command.client_tick = tank_command.client_tick + 1
    end    
end

-------------------------------------------------------------------------------
function on_broadcast( host )
    for index, tank in pairs( tanks ) do 
        local gram = m_utils.pack { 
            type = "tank", 
            index = index, 
            tank = tank, 
            client_tick = tank_commands[ index ].client_tick - 1
        } 
        host:broadcast( gram, 0, "unsequenced" ) 
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
            on_update()
            -- we broadcast 3 times slower than we update
            if tick % 3 == 0 then
                on_broadcast( host )
            end
        end
    end
end

-------------------------------------------------------------------------------
-- TODO: better start/stop control for host
-------------------------------------------------------------------------------
channel = love.thread.getChannel( "server_channel" )
value = channel:demand()
start_server( value.host, value.port )






