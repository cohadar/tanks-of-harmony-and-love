--- @module client
local client = {}

require "enet"
local conf = require "conf"
local tank = require "tank"
local utils = require "utils"
local world = require "world"
local history = require "history"
local text = require "text"

local _host = nil
local _server = nil
local _connected = false
local _indexOnServer = 0
local _clientTick = 0

-------------------------------------------------------------------------------
function client.getTick()
	return _clientTick
end

-------------------------------------------------------------------------------
function client.incTick()
	_clientTick = _clientTick + 1
	return _clientTick
end

-------------------------------------------------------------------------------
function client.isConnected()
	return _connected
end

-------------------------------------------------------------------------------
function client.init()
	-- nothing
end

-------------------------------------------------------------------------------
function client.connect( address, port )
	client.quit()
	_host = enet.host_create()
	_server = _host:connect( address .. ":" .. port )
end

-------------------------------------------------------------------------------
local function tank_sync( msg )
	if conf.NETCODE_DEBUG then
		world.update_tank( msg.index, msg.tank )
	end
	local do_sync = false
	local old_tank = history.get_tank( msg.client_tick )
	if old_tank == nil then
		text.print( "nil_sync", _clientTick, msg.client_tick )
		do_sync = true
	elseif tank.neq( old_tank, msg.tank ) then
		text.print( "forced_sync", _clientTick, msg.client_tick )
		do_sync = true
	end
	if do_sync then
		history.reset()
		world.update_tank( 0, msg.tank )
		history.tank_record( msg.client_tick, msg.tank )
		_clientTick = msg.client_tick
	end
end

-------------------------------------------------------------------------------
function client.update( tank_command )
	if _connected then
		local datagram = utils.pack{ type = "tank_command", tank_command = tank_command }
    	_server:send( datagram, 0, "unsequenced" )
	end
	if not _server then 
		return 
	end
	repeat
		event = _host:service(0)
		if event then
			if event.type == "connect" then
				text.status( "Connected to", event.peer )
			elseif event.type == "receive" then
				local msg = utils.unpack( event.data )
				if msg.type == "tank" then 
					if _indexOnServer == msg.index then
						tank_sync( msg )
					else
						world.update_tank( msg.index, msg.tank )
					end
				elseif msg.type == "index" then
					_indexOnServer = msg.index
					_connected = true
					world.connect( _indexOnServer )
					love.window.setTitle( "Connected as Player #" .. _indexOnServer )
					text.print( "index on server: ", _indexOnServer )
				elseif msg.type == "player_gone" then
					world.player_gone( msg.index )
					-- TODO: display disconnected tanks in gray for a short time
				else
					text.print("ERROR: unknown msg.type: ", msg.type, event.data )
				end
			elseif event.type == "disconnect" then
				text.status( "disconnect" )
				love.window.setTitle( "Not Connected" )
				client.quit()
				-- TODO: handle disconnect gracefully
			else 
				text.print( "ERROR: unknown event.type: ", event.type, event.data )
			end
		end
	until not event
end

-------------------------------------------------------------------------------
function client.quit()
	if _server ~= nil then
		_server:disconnect()
		_host:flush()
	end
	_server = nil
	_connected = false
end

-------------------------------------------------------------------------------
return client
