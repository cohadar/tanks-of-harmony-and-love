-------------------------------------------------------------------------------
-- embedded game server for "_tanks of Harmony and Love"
-- can NOT be run as standalone Lua app!
-- TODO: figure out how to call this in love2d console mode!
-------------------------------------------------------------------------------
require "enet"
require "love.timer"
local tank = require "tank"
local utils = require "utils"
local bullets = require "bullets"
local text = require "text"
local ticker = require "ticker"
local player = require "player"
local terrain = require "terrain"

local _tanks = {}
local _tankCommands = {}
local _players = {}

-------------------------------------------------------------------------------
local function onInit()  
    for i = 1, 256 do
        _tanks[ i ] = tank.new()
        _tankCommands[ i ] = tank.newCommand()
        _players[ i ] = player.new()
    end
end

-------------------------------------------------------------------------------
local function onConnect( event )  
    local index = event.peer:index()
    text.print( "connect", index, os.time() )
    _tanks[ index ] = tank.new()
    _tankCommands[ index ] = tank.newCommand()
    _players[ index ] = player.new()
    -- TODO: let players pick side obviously
    if index % 2 == 0 then
        _tanks[ index ].team = "red"
        _players[ index ].team = "red"
    else
        _tanks[ index ].team = "blue"
        _players[ index ].team = "blue"        
    end
    terrain.respawn( _tanks[ index ] )
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
local function onKill( tnk, index, killer_index )
    _players[ index ].deaths = _players[ index ].deaths + 1
    _players[ killer_index ].kills = _players[ killer_index ].kills + 1
    terrain.respawn( tnk )
end

-------------------------------------------------------------------------------
local function onUpdate()
    bullets.update()
    for index, tnk in pairs( _tanks ) do 
        tank_command = _tankCommands[ index ]
        tank.update( tnk, tank_command )
        tank_command.client_tick = tank_command.client_tick + 1
        local x, y, index = bullets.collider( tnk.x, tnk.y, tank.IMG_TANK_RADIUS )
        if x and y and index then
            if tank.confirmHit( tnk, x, y ) then
                tnk.hit_x = x
                tnk.hit_y = y
                tnk.hp = tnk.hp - 10 -- TODO: make damage directional
                if tnk.hp <= 0 then
                    local killer_index = index -- temporary bug for testing
                    onKill( tnk, index, index ) -- TODO: make bullets carry killer_index
                end
                bullets.remove( index )
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
    onInit()
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






