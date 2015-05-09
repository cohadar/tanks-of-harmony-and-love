-------------------------------------------------------------------------------
-- embedded game server for "_tanks of Harmony and Love"
-- can NOT be run as standalone Lua app!
-- TODO: figure out how to call this in love2d console mode!
-------------------------------------------------------------------------------
require "enet"
require "love.timer"
utils = require "utils"
tank = require "tank"
bullets = require "bullets"
text = require "text"
ticker = require "ticker"

local _tanks = {}
local _tankCommands = {}

-------------------------------------------------------------------------------
local function onConnect( event ) 
    local index = event.peer:index()
    text.print( "connect", index, os.time() )
    _tanks[ index ] = tank.new()
    _tankCommands[ index ] = tank.newCommand()
    local datagram = utils.pack{ type = "index", index = index }
    event.peer:send( datagram, 0,  "unsequenced" )
end

-------------------------------------------------------------------------------
local function onDisconnect( host, event )
    local index = event.peer:index()
    text.print( "disconnect", index )
    _tanks[ index ] = nil
    local gram = utils.pack{ type = "player_gone", index = index } 
    host:broadcast( gram )
end

-------------------------------------------------------------------------------
local function onReceive( event, server_tick )
    msg = utils.unpack( event.data )
    if msg.type == "tank_command" then
        _tankCommands[ event.peer:index() ] = msg.tank_command
    else
        text.print( "ERROR: unknown msg.type", msg.type, event.data )
    end
end

-------------------------------------------------------------------------------
local function onUpdate()
    bullets.update()
    for index, tnk in pairs( _tanks ) do 
        tank_command = _tankCommands[ index ]
        tank.update( tnk, tank_command )
        tank_command.client_tick = tank_command.client_tick + 1
        local x, y = bullets.collider( tnk.x, tnk.y, tank.IMG_TANK_RADIUS )
        if x and y then
            if tank.confirmHit( tnk, x, y ) then
                tnk.hit_x = x
                tnk.hit_y = y
            end
        end
    end    
end

-------------------------------------------------------------------------------
local function onBroadcast( host )
    for index, tnk in pairs( _tanks ) do 
        local gram = utils.pack { 
            type = "broadcast", 
            index = index, 
            tank = tnk, 
            bullets_table = bullets.exportTable(),
            client_tick = _tankCommands[ index ].client_tick - 1
        } 
        host:broadcast( gram, 0, "unsequenced" ) 
        tnk.hit_x = nil
        tnk.hit_y = nil
    end
end

-------------------------------------------------------------------------------
local function startServer( host, port )
    server_address = host .. ":" .. port
    text.print( "starting server", server_address )
    local host = enet.host_create( server_address )
    local tick = 0
    local mark = love.timer.getTime()
    ticker.init( mark )
    while true do
        local event = host:service( 0 )
        if event then
            if event.type == "receive" then
                onReceive( event, tick )
            elseif event.type == "connect" then
                onConnect( event )
            elseif event.type == "disconnect" then
                onDisconnect( host, event )
            else
                text.print( "ERROR: unknown event.type", event.type )
            end
        end
        mark = love.timer.getTime()
        while ticker.tick( mark ) do
            tick = tick + 1
            onUpdate()
            -- we broadcast 3 times slower than we update
            if tick % 3 == 0 then
                onBroadcast( host )
            end
        end
    end
end

-------------------------------------------------------------------------------
-- TODO: better start/stop control for host
-------------------------------------------------------------------------------
channel = love.thread.getChannel( "server_channel" )
value = channel:demand()
startServer( value.host, value.port )






